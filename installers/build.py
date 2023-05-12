#!/usr/bin/env python3
import os.path
import re
from typing import List
from typing import Optional
from typing import Set


def main():
    """
    Build install.sh
    """

    dotfiles = Dotfiles()

    dotfiles.compile("install.sh")
    dotfiles.compile("update.sh")


SOURCE = re.compile(r"^(\s*)#.*?source=(\w\S+)(\s+.*$)")
PRELUDE_END = re.compile(r"^set -eu\s*$")

BUILD_WARNING = """
{bar}
# {destination} is a GENERATED FILE #
{bar}

# All changes should be made to {source}
# and included files therin, as the root one is compiled
"""


class Dotfiles:
    def __init__(self) -> None:
        self.installers = os.path.dirname(__file__)
        self.dotfiles = os.path.dirname(self.installers)

    def compile(self, filename: str) -> None:
        source = os.path.join(self.installers, filename)
        Script(
            dotfiles=self.dotfiles, destination=os.path.join(self.dotfiles, filename)
        ).process(source)


class Script:
    def __init__(self, dotfiles: str, destination: str):
        self.include_prelude = True
        self.imports: Set[str] = set()
        self.dotfiles = dotfiles
        self.destination_file = open(destination, "w")
        self.destination = os.path.relpath(destination, self.dotfiles)
        self.indents: List[str] = []

    def write(self, line: str) -> None:
        if line.strip() == "":
            # Avoid writing blank lines with only whitespace from indents
            self.destination_file.write("\n")
            return
        indent = "".join(self.indents)
        self.destination_file.write(indent + line)

    def write_line(self, line: str) -> None:
        self.write(line + "\n")

    def write_warning(self, filename: str) -> None:
        bar_size = (
            len(self.destination)
            + len(BUILD_WARNING.splitlines()[2])
            - len("{destination}")
        )
        self.write(
            BUILD_WARNING.format(
                destination=self.destination,
                bar="#" * bar_size,
                source=os.path.relpath(filename, self.dotfiles),
            )
        )

    def process(self, filename: str) -> None:
        line: Optional[str]
        with open(filename, "r") as source:
            for line in source:
                if self.include_prelude:
                    self.write(line)
                if re.match(PRELUDE_END, line):
                    if self.include_prelude:
                        # Now we can include the warning
                        self.write_warning(filename)
                    # We have included the prelude once, don't do it again
                    self.include_prelude = False

                    break
            else:
                raise ValueError(f"{filename} contained no content after prelude")

            # Use while-true here becasue we might want to skip multiple lines.
            blank_line = False
            while True:
                line = next(source, None)
                if line is None:
                    # All done here
                    break
                if line.strip() == "":
                    blank_line = True
                    # Skip blank lines
                    continue
                if blank_line:
                    blank_line = False
                    self.write_line("")
                match = re.match(SOURCE, line)
                if match:
                    tags = match.group(3)
                    if "no-include" in tags:
                        self.write(line)
                    else:
                        # Skip the next line too
                        next(source, None)
                        self.indents.append(match.group(1))
                        include = os.path.join(self.dotfiles, match.group(2))
                        include_relpath = os.path.relpath(include, self.dotfiles)
                        if include_relpath in self.imports:
                            self.write_line(f"# Already included {include_relpath}")
                            self.write(line)
                            self.write_line("")
                        else:
                            self.imports.add(include_relpath)
                            self.write_line("")
                            self.write_line(f"# BEGIN included from {include_relpath}")
                            self.write_line("")
                            self.process(include)
                            self.write_line("")
                            self.write_line(f"# END included from {include_relpath}")
                            self.write_line("")
                        self.indents.pop()
                else:
                    self.write(line)


if __name__ == "__main__":
    main()
