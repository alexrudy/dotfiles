#!/usr/bin/env python3
import urllib.parse
import dataclasses as dc
import re

from typing import Any, Dict, List, Optional

try:
    import requests
except ImportError:
    print("Please install requests")
    exit(1)

from rich.progress import Progress, BarColumn, TextColumn, TimeElapsedColumn

LATEST_API_VERSION: str = "2022-11-28"
CODEOWNERS_COMMENT: str = "<!-- automated codeowners info comment -->"

FIND_OWNER_LINK: re.Pattern = re.compile(
    r"\s*:(?P<emoji>\w+):\s+\[(?P<team>[\w\s]+)(:?\(required\))?\s*\]\("
)


class Links(dict):
    def __getitem__(self, key: str) -> Dict[str, str]:
        return super().__getitem__(key)["href"]

    def __repr__(self) -> str:
        return f"<{self.__class__.__name__} {super().__repr__()}>"


@dc.dataclass
class Github:
    token: str
    api_version: str = LATEST_API_VERSION
    base_url: str = "https://api.github.com"
    session: requests.Session = dc.field(init=False)

    def __post_init__(self):
        self.session = requests.Session()
        self.session.headers.update(
            {
                "Authorization": f"Bearer {self.token}",
                "Accept": "application/vnd.github+json",
                "X-GitHub-Api-Version": self.api_version,
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
        yield from response.json()
        while "next" in response.links:
            response = self.get(response.links["next"]["url"])
            response.raise_for_status()
            yield from response.json()


@dc.dataclass(init=False)
class Resource:
    _data: Dict[str, Any]
    _links: Dict[str, Any]

    def __init__(self, data: Dict[str, Any], links: Optional[Dict[str, Any]] = None):
        self._data = data
        self._links = links or {}

    @classmethod
    def from_response(cls, response: requests.Response) -> "Resource":
        return cls(response.json(), response.links)

    def __getitem__(self, key: str) -> Any:
        return self._data[key]

    def __repr__(self) -> str:
        return f"<{self.__class__.__name__} {self._data['id']}>"

    @property
    def links(self) -> Links:
        return Links(self._data["_links"])


class Notification(Resource):
    def nosiy(self, repo: str) -> bool:
        return (
            self._data["repository"]["full_name"] == repo
            and self._data["reason"] == "review_requested"
        )

    def thread(self) -> str:
        return self._data["id"]

    def subject_url(self) -> str:
        return self._data["subject"]["url"]

    def unsubscribe(self, github: Github) -> None:
        thread = self.thread()
        github.patch(f"notifications/threads/{thread}")
        github.delete(f"notifications/threads/{thread}")


class PullRequest(Resource):
    def requested_reviewers(self) -> List[str]:
        return [rr["login"] for rr in self._data["requested_reviewers"]]

    def requested_teams(self) -> List[str]:
        return [rrt["name"] for rrt in self._data["requested_teams"]]


class Comment(Resource):
    def body(self) -> str:
        return self._data["body"]

    def user(self) -> str:
        return self._data["user"]["login"]


@dc.dataclass
class CodeOwners:
    required: List[str]
    optional: List[str]
    completed: List[str]

    @property
    def mentioned(self) -> List[str]:
        return self.required + self.optional + self.completed

    @classmethod
    def parse(cls, comment: Comment) -> Optional["CodeOwners"]:
        if CODEOWNERS_COMMENT not in comment.body():
            # not an automated comment, ignore
            return None

        required: List[str] = []
        optional: List[str] = []
        completed: List[str] = []

        for line in comment.body().splitlines():
            m = FIND_OWNER_LINK.match(line)
            if m:
                if m.group("emoji") == "white_check_mark":
                    completed.append(m.group("team").strip())
                elif m.group("emoji") == "x":
                    required.append(m.group("team").strip())
                elif m.group("emoji") == "information_source":
                    optional.append(m.group("team").strip())

        return cls(required, optional, completed)


if __name__ == "__main__":
    import argparse
    import sys
    import concurrent.futures
    import contextlib

    parser = argparse.ArgumentParser()
    parser.add_argument("--token", help="Github token to use", required=True)
    parser.add_argument(
        "--repo", help="Repository to unsubscribe from", default="discord/discord"
    )
    parser.add_argument(
        "--bot", help="Bot to unsubscribe from", default="discord-ci-app[bot]"
    )
    args = parser.parse_args()

    github = Github(args.token)
    unsubs = set()
    with contextlib.ExitStack() as stack:
        executor = stack.enter_context(
            concurrent.futures.ThreadPoolExecutor(max_workers=10)
        )

        progress = stack.enter_context(
            Progress(
                "[progress.description]{task.description}",
                BarColumn(),
                TimeElapsedColumn(),
                TextColumn("{task.completed}"),
            )
        )

        task_notifications = progress.add_task("Notifications", total=None)
        unsubscribes = progress.add_task("Unsubscribes", total=None)

        def unsubscribe(notification):
            future = executor.submit(notification.unsubscribe, github)
            future.add_done_callback(lambda _: progress.update(unsubscribes, advance=1))

        for notification in (
            Notification(data) for data in github.get_paginated_data("notifications")
        ):
            progress.update(task_notifications, advance=1)
            repo = notification["repository"]["full_name"]

            if repo != args.repo and repo.startswith("discord/"):
                if repo not in unsubs:
                    print(f"Unsubscribing from {repo}")
                    github.delete(f"/repos/{repo}/subscription")
                    unsubs.add(repo)
                unsubscribe(notification)
                continue

            if notification.nosiy(args.repo):
                pr = PullRequest.from_response(github.get(notification.subject_url()))
                if "alexrudy" in pr.requested_reviewers():
                    continue

                # PR isn't open, unsubscribe
                if pr["state"] != "open":
                    unsubscribe(notification)
                    continue

                # Team isn't a requested reviewer, unsubscribe
                if "ML Platform" not in pr.requested_teams():
                    unsubscribe(notification)
                    continue

                comments = (
                    Comment(data)
                    for data in github.get_paginated_data(pr.links["comments"])
                )
                for comment in comments:
                    if comment.user() == "discord-ci-app[bot]":
                        codeowners = CodeOwners.parse(comment)
                        if codeowners is not None:
                            if "Machine Learning Platform" in codeowners.mentioned:
                                unsubscribe(notification)
                            else:
                                print(f"Unprocessed {comment.user()} comment:")
                                print(comment.body())
                                print(pr.links["html"])
                                sys.exit(1)
