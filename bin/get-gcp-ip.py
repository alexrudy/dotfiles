#!/usr/bin/env /Users/alexrudy/.pyenv/versions/bitly-boto/bin/python

import subprocess
import click
import re
import tempfile
import shlex
import os
import typing as t
from pathlib import Path
from collections import OrderedDict


@click.command()
@click.option(
    "--name", type=str, help="Name of the GCE instance to query for.", required=True
)
@click.option("--username", type=str, help="Username for the GCE instance")
@click.option("--hostname", type=str, help="Hostname in the SSH Config.")
@click.option("--config", type=str, help="Path to the SSH Config to update.")
@click.option(
    "--key-file", type=str, default="~/.ssh/id_rsa", help="Path to SSH key file"
)
@click.option("--zone", type=str, help="GCE Zone")
def main(name, hostname, username, config, key_file, zone):
    """Find a GCE box by name and print the IP address for it.

    Optionally, update the `HOSTNAME` line in an SSH config
    """
    key_file = os.path.expanduser(key_file)

    args = [
        "gcloud",
        "compute",
        "ssh",
        f"{username}@{name}",
        f"--ssh-key-file={key_file}",
        "--dry-run",
    ]
    if zone:
        args.append(f"--zone={zone}")

    raw_cmd = subprocess.check_output(args).decode("utf-8").strip()
    args = shlex.split(raw_cmd)

    user, address = args[-1].split("@", 1)

    config_options = {}
    for i, arg in enumerate(args):
        if arg == "-o":
            copt = args[i + 1]
            name, value = copt.split("=", 1)
            config_options[name.lower()] = value

    click.echo(f"IP: {address}")

    config_options["hostname"] = address
    config_options["user"] = user

    if config is not None and hostname is not None:
        click.echo(f"Updating {config!s} {hostname}")
        update_config(config, hostname, config_options)


def update_config(config, hostname, config_options):
    """Update the SSH Config with a new IP address"""
    target = Path(config)

    with tempfile.TemporaryDirectory() as tmpdirname:
        target_backup = Path(tmpdirname) / target.name

        with target_backup.open("w") as out_stream, target.open("r") as in_stream:
            for line in iter_new_config(in_stream, hostname, config_options):
                out_stream.write(line)

        target_backup.replace(target)


class Entry(t.NamedTuple):
    line: str
    match: t.Optional[re.Match]

    @property
    def key(self) -> t.Optional[str]:
        return self.match.group("key").lower() if self.match else None

    @property
    def value(self) -> t.Optional[str]:
        return self.match.group("value")

    @classmethod
    def parse(cls, line) -> t.Optional["Entry"]:
        m = re.match(
            r"^(?P<indent>\s*)(?P<key>\w+)(?P<sep>=|\s+)(?P<value>\S.+\S?)(?P<comment>\s+#.+)?$",
            line,
            flags=re.I,
        )
        return cls(line, m)

    def replace(self, value: str):

        return (
            self.match.expand("\g<indent>\g<key>\g<sep>")
            + value
            + self.match.expand("\g<comment>")
            + "\n"
        )


def iter_new_config(lines, target_host, new_options):
    options = set()

    new_options = {k.lower().strip(): v for k, v in new_options.items()}

    # Construct the entire config in memory

    config = OrderedDict()
    current_hosts = frozenset()
    for line in lines:
        entry = Entry.parse(line)

        if entry.key == "host":
            current_hosts = frozenset(entry.value.split())
            config[current_hosts] = host_config = OrderedDict()
            host_config[entry.key] = entry
        else:
            host_config[entry.key] = entry

    # Iterate and retrun modified configuration
    for hosts, host_config in config.items():

        for entry in host_config.values():
            line = entry.line
            if target_host in hosts and entry.key in new_options:
                new_value = new_options[entry.key]
                if new_value != entry.value:
                    line = entry.replace(new_value)
                options.add(entry.key)
            yield line

    if not options:
        raise ValueError("No options were replaced")


if __name__ == "__main__":
    main(auto_envvar_prefix="GET_GCP_IP")
