#!/usr/bin/env python3

import click
import configparser
import os

@click.command()
@click.argument("key")
@click.option("--profile", default='default', type=str, help='AWS profile to update')
@click.option("--config", "config_path", default=os.path.expanduser('~/.aws/credentials'), type=click.Path())
def main(key, profile, config_path):
    """Read value 'key' from a vault"""
    config = configparser.ConfigParser()
    config.read(config_path)

    items = []

    profile_config = config[profile]
    if key in profile_config:
        items.append((key, profile_config[key].strip()))
    else:
        for pkey in profile_config.keys():
            if key in pkey:
                items.append((pkey, profile_config[pkey].strip()))

    if not items:
        click.echo("Can't find key={} in profile={}".format(key, profile))
        raise click.Abort()
    elif len(items) > 1:
        for key, value in items:
            click.echo("{}={}".format(key, value))
    else:
        key, value = items[0]
        click.echo(value)

if __name__ == '__main__':
    main()
