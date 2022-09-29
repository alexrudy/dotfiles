#!/usr/bin/env /Users/alexrudy/.pyenv/versions/bitly-boto/bin/python

import boto3
import click
import re
import tempfile
from pathlib import Path


@click.command()
@click.option(
    "--name", type=str, help="Name of the EC2 instance to query for.", required=True
)
@click.option("--hostname", type=str, help="Hostname in the SSH Config.")
@click.option("--config", type=str, help="Path to the SSH Config to update.")
def main(name, hostname, config):
    """Find an EC2 box by name and print the IP address for it.

    Optionally, update the `HOSTNAME` line in an SSH config
    """

    ec2 = boto3.resource("ec2")

    filters = [{"Name": "tag:Name", "Values": [name]}]
    instances = ec2.instances.filter(Filters=filters)

    click.echo(f"Name: {name}")
    try:
        instance = next(iter(instances))
    except StopIteration:
        click.echo("No instance found...")
        raise click.Abort()

    click.echo(f"IP: {instance.public_ip_address}")
    if config is not None and hostname is not None:
        click.echo(f"Updating {config!s}")
        update_config(config, hostname, instance.public_ip_address)


def update_config(config, hostname, ip_address):
    """Update the SSH Config with a new IP address"""
    target = Path(config)

    with tempfile.TemporaryDirectory() as tmpdirname:
        target_backup = Path(tmpdirname) / target.name

        with target_backup.open("w") as out_stream, target.open("r") as in_stream:
            for line in iter_new_config(in_stream, hostname, ip_address):
                out_stream.write(line)

        target_backup.replace(target)


def iter_new_config(lines, target_host, new_address):
    host = None
    for line in lines:
        m = re.match(r"\s*host(=|\s+)(.+?)(#.+)?", line, flags=re.I)
        if m:
            host = m.group(2)

        m = re.match(r"\s*hostname(=|\s+)(.+?)(#.+)?", line, flags=re.I)
        if m and host == target_host:
            oldip = m.group(2)
            line = line.replace(oldip, new_address)

        yield line


if __name__ == "__main__":
    main(auto_envvar_prefix="GET_EC2_IP")
