#!/usr/bin/env python3

import click
import requests

@click.command()
@click.argument("language")
@click.option("--append/--no-append", default=True)
def main(language, append):
    """Get a language's git ignore"""
    resp = requests.get(f"https://raw.githubusercontent.com/github/gitignore/raw/master/{language}.gitignore")
    with open(".gitignore", 'a' if append else 'w') as handle:
        handle.write(resp.text)
    
if __name__ == '__main__':
    main()
