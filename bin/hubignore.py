#!/usr/bin/env python3

import click
import requests

BASE_URL = "https://raw.githubusercontent.com/github/gitignore/master/"


@click.command()
@click.argument("language")
@click.option("--append/--no-append", default=True)
def main(language, append):
    """Get a language's git ignore"""

    variations = [language.capitalize(), language.lower(), language.upper()]

    initial_resp = requests.get(f"{BASE_URL}{language}.gitignore")
    if initial_resp.status_code == 200:
        resp = initial_resp
    else:
        for variation in variations:
            resp = requests.get(f"{BASE_URL}{variation}.gitignore")
            if resp.status_code == 200:
                break
        else:
            initial_resp.raise_for_status()

    with open(".gitignore", "a" if append else "w") as handle:
        handle.write(resp.text)


if __name__ == "__main__":
    main()
