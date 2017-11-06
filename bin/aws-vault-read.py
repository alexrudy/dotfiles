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
    click.echo(config[profile][key])

if __name__ == '__main__':
    main()