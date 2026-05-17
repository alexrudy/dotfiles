#!/usr/bin/env python3
import dataclasses as dc
import re
import urllib.parse
from typing import Any, Dict

try:
    import requests
except ImportError:
    print("Please install requests")
    exit(1)


FIND_OWNER_LINK: re.Pattern = re.compile(
    r"\s*:(?P<emoji>\w+):\s+\[(?P<team>[\w\s]+)(:?\(required\))?\s*\]\("
)


class Links(dict):
    def __getitem__(self, key: str) -> Dict[str, str]:
        return super().__getitem__(key)["href"]

    def __repr__(self) -> str:
        return f"<{self.__class__.__name__} {super().__repr__()}>"


@dc.dataclass
class Linode:
    token: str
    base_url: str = "https://api.linode.com/v4/"
    session: requests.Session = dc.field(init=False)

    def __post_init__(self):
        self.session = requests.Session()
        self.session.headers.update(
            {
                "Authorization": f"Bearer {self.token}",
            }
        )

    def get(self, endpoint: str, **kwargs: Any) -> requests.Response:
        return self.session.get(urllib.parse.urljoin(self.base_url, endpoint), **kwargs)

    def post(self, endpoint: str, **kwargs: Any) -> requests.Response:
        return self.session.post(
            urllib.parse.urljoin(self.base_url, endpoint), **kwargs
        )

    def patch(self, endpoint: str, **kwargs: Any) -> requests.Response:
        return self.session.patch(
            urllib.parse.urljoin(self.base_url, endpoint), **kwargs
        )

    def delete(self, endpoint: str, **kwargs: Any) -> requests.Response:
        return self.session.delete(
            urllib.parse.urljoin(self.base_url, endpoint), **kwargs
        )

    def get_paginated_data(self, endpoint: str, **kwargs: Any) -> Any:
        response = self.get(endpoint, **kwargs)
        response.raise_for_status()

        params = kwargs.pop("params", {})

        data = response.json()

        yield from data["data"]

        page = data.get("page", 0)
        pages = data.get("pages", 0)

        while page < pages:
            response = self.get(
                endpoint, params=dict(page=page + 1, **params), **kwargs
            )
            response.raise_for_status()
            data = response.json()

            yield from data["data"]

            page = data.get("page", 0)
            pages = data.get("pages", 0)


def cleanup_acme_dns(linode: Linode, target: str):
    for i, domain in enumerate(linode.get_paginated_data("domains")):
        if domain.get("domain") == target:
            break
    else:
        print("Domain not found", flush=True)
        raise SystemExit(1)

    domain_id = domain.get("id")
    for i, record in enumerate(
        linode.get_paginated_data(f"domains/{domain_id}/records")
    ):
        if record.get("type") in ("TXT"):
            if record.get("name", "").startswith("_acme"):
                print(f"deleting {record.get('name', '')!r}")
                linode.delete(f"domains/{domain_id}/records/{record.get('id')}")


if __name__ == "__main__":
    import argparse

    parser = argparse.ArgumentParser()
    parser.add_argument("--token", help="Linode token to use", required=True)

    subs = parser.add_subparsers(dest="command")
    cleanup_parser = subs.add_parser(
        name="clean-acme-dns", description="cleanup acme DNS TXT entries"
    )
    cleanup_parser.add_argument("domain", help="Domain to search for when cleaning")

    args = parser.parse_args()

    linode = Linode(args.token)

    if args.command == "clean-acme-dns":
        cleanup_acme_dns(linode, args.domain)
