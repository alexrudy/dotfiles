import argparse
import dataclasses as dc
from pathlib import Path


def main():
    """Uninstall the dotfiles."""

    parser = argparse.ArgumentParser(description="Uninstall linked dotfiles.")
    parser.add_argument(
        "--dry-run", action="store_true", help="Print what would be done."
    )

    args = parser.parse_args()

    if not args.dry_run:
        args.dry_run = True

    home = Path.home()
    dotfiles = Dotfiles(home / ".dotfiles")

    for file in home.iterdir():
        if not file.name.startswith("."):
            continue
        if not file.is_symlink():
            continue

        target = file.resolve()

        if target in dotfiles:
            if args.dry_run:
                print(f"Would remove link {file} -> {target}")
            else:
                file.unlink()
                print(f"Removed link {file} -> {target}")


@dc.dataclass
class Dotfiles:
    path: Path

    def __contains__(self, item):
        if isinstance(item, str):
            item = Path(item)
        if not isinstance(item, Path):
            return False

        return item.is_relative_to(self.path)


if __name__ == "__main__":
    main()
