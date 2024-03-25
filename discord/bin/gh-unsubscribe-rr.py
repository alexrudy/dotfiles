#!/usr/bin/env python3
import urllib.parse
import contextlib
import collections
import dataclasses as dc
import re

from typing import Any, Dict, List, Optional, Self, TypeVar, Iterable

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


R = TypeVar("R", bound="Resource")


class Links(dict):
    def __getitem__(self, key: str) -> str:
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

    def get_paginated_data(
        self, endpoint: str, **kwargs: Any
    ) -> Iterable[Dict[str, Any]]:
        response = self.get(endpoint, **kwargs)
        response.raise_for_status()
        yield from response.json()
        while "next" in response.links:
            response = self.get(response.links["next"]["url"])
            response.raise_for_status()
            yield from response.json()

    def get_paginated_resource(
        self, cls: type[R], endpoint: str, **kwargs: Any
    ) -> Iterable[R]:
        for item in self.get_paginated_data(endpoint=endpoint, **kwargs):
            yield cls(item)


@dc.dataclass(init=False)
class Resource:
    _data: Dict[str, Any]
    _links: Dict[str, Any]

    def __init__(self, data: Dict[str, Any], links: Optional[Dict[str, Any]] = None):
        self._data = data
        self._links = links or {}

    @classmethod
    def from_response(cls, response: requests.Response) -> "Self":
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
        return self.repo() == repo and self["reason"] == "review_requested"

    def repo(self) -> str:
        return self._data["repository"]["full_name"]

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


class UnprocessableComment(Exception):
    def __init__(self, comment: Comment) -> None:
        self.msg = f"Unprocessed {comment.user()} comment"

    def __str__(self) -> str:
        lines = [f"Unprocessed {comment.user()} comment:"]
        lines.extend(comment.body().splitlines())
        lines.append(pr.links["html"])

        return "\n".join(lines)


@contextlib.contextmanager
def handle_unprocessable_comment():
    try:
        yield
    except UnprocessableComment as exc:
        print(str(exc))
        raise SystemExit(1)


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

        if not any((required, optional, completed)):
            raise UnprocessableComment(comment)

        return cls(required, optional, completed)


if __name__ == "__main__":
    import argparse
    import concurrent.futures
    import contextlib

    parser = argparse.ArgumentParser()
    parser.add_argument("--token", help="Github token to use", required=True)
    parser.add_argument(
        "--repo", help="Repository to unsubscribe from", default="discord/discord"
    )
    parser.add_argument(
        "--organization",
        help="Github Organization to consider (others will be skipped)",
        default="discord",
    )
    parser.add_argument(
        "--bot", help="Bot to unsubscribe from", default="discord-ci-app[bot]"
    )
    parser.add_argument("--team", help="Github team to target", default="ML Platform")
    parser.add_argument(
        "--owners-team",
        help="Team name from codeowners",
        default="Machine Learning Platform",
    )
    args = parser.parse_args()

    github = Github(args.token)
    stats: collections.Counter[str] = collections.Counter()
    unsubs = set()
    with contextlib.ExitStack() as stack:
        executor = stack.enter_context(
            concurrent.futures.ThreadPoolExecutor(max_workers=10)
        )

        stack.enter_context(handle_unprocessable_comment())

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

        def update_unsubscribes(*args) -> None:
            progress.update(unsubscribes, advance=1)
            stats["threads"] += 1

        def unsubscribe(notification):
            future = executor.submit(notification.unsubscribe, github)
            future.add_done_callback(update_unsubscribes)

        for notification in github.get_paginated_resource(
            Notification, "notifications"
        ):
            progress.update(task_notifications, advance=1)
            stats["notifications"] += 1

            if notification.repo() != args.repo and notification.repo().startswith(
                f"{args.organization}/"
            ):
                if notification.repo() not in unsubs:
                    print(f"Unsubscribing from {notification.repo()}")
                    github.delete(f"/repos/{notification.repo()}/subscription")
                    unsubs.add(notification.repo())
                unsubscribe(notification)
                stats["other-discord-repo"] += 1
                continue

            if notification.nosiy(args.repo):
                pr = PullRequest.from_response(github.get(notification.subject_url()))
                if "alexrudy" in pr.requested_reviewers():
                    stats["personally-requested"] += 1
                    continue

                # PR isn't open, unsubscribe
                if pr["state"] != "open":
                    stats["closed"] += 1
                    unsubscribe(notification)
                    continue

                # Team isn't a requested reviewer, unsubscribe
                if args.team not in pr.requested_teams():
                    stats["no-longer-requested"] += 1
                    unsubscribe(notification)
                    continue

                for comment in github.get_paginated_resource(
                    Comment, pr.links["comments"]
                ):
                    if comment.user() == args.bot:
                        stats["codeowners-comments"] += 1
                        codeowners = CodeOwners.parse(comment)
                        if codeowners is not None:
                            if args.owners_team in codeowners.mentioned:
                                stats["team-codeowners"] += 1
                                unsubscribe(notification)
            elif notification.repo() == args.repo:
                stats[f"reason-{notification['reason']}"] += 1
            else:
                stats["repo-{}".format(notification.repo())] += 1

    print("Overall stats:")
    print("Processed {} notifications".format(stats["notifications"]))
    if stats["threads"]:
        print("Unsubscribed from {} threads".format(stats["threads"]))
        print(" {} were closed".format(stats["closed"]))
        print(" {} did not request ML Platform".format(stats["no-longer-requested"]))
        print(
            " {} requested ML-platform via Codeowners".format(stats["team-codeowners"])
        )

    print("{} notifications were processed".format(stats["notifications"]))
    if stats["codeowners-comments"]:
        print(
            "{} codeowners comments (from {}) were processed".format(
                stats["codeowners-comments"], args.bot
            )
        )

    for key, value in stats.items():
        if key.startswith("reason-"):
            reason = key.removeprefix("reason-")
            print(" {} were triggered because {}".format(value, reason))
    print(" {} requested me persoanlly".format(stats["personally-requested"]))
    if unsubs:
        print(
            " {} belonged to other {}/ repos".format(
                stats["other-repo"], args.organization
            )
        )

    not_discord = 0
    for key, value in stats.items():
        if key.startswith("repo-"):
            repo = key.removeprefix("repo-")
            if not repo.startswith(f"{args.organization}/"):
                not_discord += value
            else:
                print(" {} belonged to {}".format(value, repo))
    if not_discord:
        print(
            " {} belonged to repos outside the {}/ organization".format(
                not_discord, args.organization
            )
        )
    print("")
    print(f"Unsubscribed from {len(unsubs)} repos")
