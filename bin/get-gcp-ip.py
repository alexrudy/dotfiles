#!/usr/bin/env /Users/alexrudy/.pyenv/versions/bitly-boto/bin/python

import subprocess
import click
import re
import tempfile
import shlex
import os
from pathlib import Path


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
def main(name, hostname, username, config, key_file):
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
    raw_cmd = subprocess.check_output(
        args
    ).decode('utf-8').strip()
    args = shlex.split(raw_cmd)

    user, address = args[-1].split("@", 1)

    config_options = {}
    for i, arg in enumerate(args):
        if arg == "-o":
            copt = args[i + 1]
            name, value = copt.split("=", 1)
            config_options[name.lower()] = value

    click.echo(f"IP: {address}")

    config_options['hostname'] = address
    config_options['user'] = user

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


def iter_new_config(lines, target_host, new_options):
    host = None
    indent = 0
    options = set()
    for line in lines:

        
        m = re.match(r"\s*host(=|\s+)(.+?)(#.+)?", line, flags=re.I)
        if m:
            # We are about to change hosts, yield config values for last host first.
            if host == target_host:
                for key in new_options.keys() - options:
                    yield f"{' ' * indent}{key} {value}"
                options.update(new_options.keys())
            host = m.group(2)

        m = re.match(r"(?P<indent>\s*)(?P<key>\w+)(?P<sep>=|\s+)(?P<value>.+?)(?P<comment>#.+)?", line, flags=re.I)
        if m and host == target_host:
            indent = len(m.group('indent'))
            key = m.group('key')
            value = m.group('value')
            
            if key in new_options:
                new_value = new_options[key]
                line = line.replace(value, new_address)
                options.add(key)

        yield line

    
        if host == target_host:
            for key in new_options.keys() - options:
                yield f"{' ' * indent}{key} {value}"
            options.update(new_options.keys())

    


if __name__ == "__main__":
    main(auto_envvar_prefix="GET_GCP_IP")

