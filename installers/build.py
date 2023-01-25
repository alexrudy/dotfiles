#!/usr/bin/env python3

import re
import os.path
from typing import IO


def main():
    """
    Build install.sh
    """

    installers = os.path.dirname(__file__)
    dotfiles = os.path.dirname(installers)
    source = os.path.join(installers, "install.sh")

    with open(os.path.join(dotfiles, "install.sh"), "w") as destination:
        process_includes(source, destination, dotfiles, prelude=True)


SOURCE = re.compile(r"^#.*?source=(\w\S+)(\s+.*$)")
PRELUDE_END = re.compile(r"^set -eu\s*$")


def process_includes(
    filename: str, destination: IO[str], dotfiles: str, prelude: bool = False
) -> None:
    with open(filename, "r") as source:
        while True:
            if not prelude:
                line = next(source, None)
                if line is None:
                    raise ValueError(f"{filename} contained no content after prelude")
                if re.match(PRELUDE_END, line):
                    prelude = True
                continue
            line = next(source, None)
            if line is None:
                # All done here
                break
            match = re.match(SOURCE, line)
            if match:
                tags = match.group(2)
                if "no-include" in tags:
                    destination.write(line)
                else:
                    # Skip the next line too
                    next(source, None)
                    include = os.path.join(dotfiles, match.group(1))
                    include_relpath = os.path.relpath(include, dotfiles)
                    destination.write(f"\n# BEGIN included from {include_relpath}\n")
                    process_includes(include, destination, dotfiles)
                    destination.write(f"\n# END included from {include_relpath}\n")
            else:
                destination.write(line)


if __name__ == "__main__":
    main()
