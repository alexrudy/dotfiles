#!/usr/bin/env python3
from __future__ import print_function
import glob
import logging
import os
import argparse
import itertools
import sys
import warnings
import string
import subprocess
import shutil

# Python2 fixes
if sys.version_info[0] < 3:
    input = raw_input

log = logging.getLogger()

join = os.path.join


class _Getch:
    """Gets a single character from standard input.  Does not echo to the
    screen."""

    def __init__(self):
        try:
            self.impl = _GetchWindows()
        except ImportError:
            self.impl = _GetchUnix()

    def __call__(self):
        return self.impl()


class _GetchUnix:
    def __init__(self):
        import tty, sys

    def __call__(self):
        import sys, tty, termios

        fd = sys.stdin.fileno()
        old_settings = termios.tcgetattr(fd)
        try:
            tty.setraw(sys.stdin.fileno())
            ch = sys.stdin.read(1)
        finally:
            termios.tcsetattr(fd, termios.TCSADRAIN, old_settings)
        return ch


class _GetchWindows:
    def __init__(self):
        import msvcrt

    def __call__(self):
        import msvcrt

        return msvcrt.getch()


getch = _Getch()


MODE_INTERACTIVE = "i"
MODE_SKIP = "s"
MODE_OVERWRITE = "o"
MODE_BACKUP = "b"
MODE_MERGE = "m"
MODES = set((MODE_INTERACTIVE, MODE_SKIP, MODE_OVERWRITE, MODE_BACKUP, MODE_MERGE))

ACTION_SUCCESS = "success"
ACTION_ASK = "ask"
ACTION_NOTHING = "nothing"

HOME = os.environ["HOME"]

MODES_INFO = {
    MODE_SKIP: "[s]kip, [S]kip all",
    MODE_OVERWRITE: "[o]verwrite, [O]verwrite all",
    MODE_BACKUP: "[b]ackup, [B]ackup all",
    MODE_MERGE: "[m]erge, [M]erge all",
}


class Installer(object):
    def __init__(self, source=os.getcwd(), home=HOME, dryrun=False, mode=MODE_INTERACTIVE):
        super(Installer, self).__init__()
        self.source = source
        self.home = os.path.expanduser(home)
        self.dryrun = dryrun
        self.initial_mode = self.mode = mode.lower()
        self.sticky = mode.lower() != mode

    def run(self):

        dotfiles = join(self.source, "**", "*.symlink")
        dotdirs = join(self.source, "**", "*.dir")

        dirreset = False

        for path in itertools.chain.from_iterable(glob.iglob(c, recursive=True) for c in (dotfiles, dotdirs)):

            if os.path.isdir(path) and not dirreset:
                dirreset, self.mode = True, self.initial_mode

            self.install_path(path)

    def install_path(self, source):

        destination = self.destination_path(source)
        sticky = False

        result = self.install(source, destination, self.mode)

        while result == ACTION_ASK:
            log.debug("Asking about {0}".format(destination))
            mode, sticky = self.ask(destination)
            result = self.install(source, destination, mode)

        if sticky:
            self.mode = mode

    def ask(self, target):
        """Ask about installing a particular item."""

        kind = "Dotdir" if os.path.isdir(target) else "Dotfile"

        options = set(MODES)
        if kind == "Dotfile":
            options.remove("m")

        helps = ", ".join([MODES_INFO[m] for m in sorted(options) if m in MODES_INFO] + ["[q]uit"])

        print("{0:s} already exists: {1:s}, what do you want to do?".format(kind, target))
        print(helps)
        ans = getch()
        c = ans[0]
        while c.lower() not in MODES:
            if c in "qQ":
                raise SystemExit()
            print("Can't understand your input: {0}".format(ans))
            ans = getch()
            c = ans[0]

        if c.lower() == c:
            return c, False
        return c.lower(), True

    def install(self, source, destination, mode):
        """Install a path in the given home directory"""

        log.debug("Checking {0} -> {1} ({2})".format(source, destination, os.path.realpath(destination)))
        if os.path.lexists(destination) and os.path.realpath(destination) == source:
            log.debug("Link for {0} already exists".format(destination))
            return ACTION_SUCCESS
        if os.path.lexists(destination):
            if mode == MODE_INTERACTIVE:
                log.debug("Interactive mode for {0}".format(destination))
                return ACTION_ASK
            elif mode == MODE_SKIP:
                log.info("Skipping {0}".format(os.path.basename(source)))
                return ACTION_NOTHING
            elif mode == MODE_MERGE and not os.path.isdir(destination):
                log.debug("Interactive mode for {0} (mode was 'merge', but this isn't a directory)".format(destination))
                return ACTION_ASK
            elif mode == MODE_MERGE:
                self.merge(source, destination)
                return ACTION_SUCCESS
            elif mode == MODE_OVERWRITE:
                log.warning("Overwriting {0}".format(destination))
                self.remove(destination)
                self.symlink(source, destination)
                return ACTION_SUCCESS
            elif mode == MODE_BACKUP:
                self.backup(destination)
                self.symlink(source, destination)
                return ACTION_SUCCESS

            else:
                raise ValueError("Mode = {0}".format(mode))

        else:
            self.symlink(source, destination)
            return ACTION_SUCCESS

    def rename(self, source, target):
        log.debug("mv {0} {1}".format(source, target))
        if not self.dryrun:
            os.rename(source, target)

    def remove(self, source):
        log.debug("rm {0}".format(source))
        if not self.dryrun:
            os.remove(source)

    def symlink(self, source, destination):
        log.info("Linking {0}".format(os.path.basename(source)))
        log.debug("ln -s {0} {1}".format(source, destination))
        if not self.dryrun:
            os.symlink(source, destination)

    def destination_path(self, source):
        """
        Compute the destination path given a source path and a home directory
        """
        target = join(self.home, ".{0:s}".format(os.path.splitext(os.path.basename(source))[0]))

        prefix = os.path.commonpath([os.path.abspath(p) for p in (os.path.realpath(target), source)])
        correct = os.path.abspath(self.home) in prefix

        if not correct:
            raise ValueError("Unexpected target path {0} for soruce {1}".format(target, source))
        return target

    def backup(self, target, n_check=10):
        bfname = "{0}.backup".format(target)
        for i in range(n_check):
            if i:
                bfname = target + ".{:d}.backup".format(i)
            if not os.path.exists(bfname):
                self.rename(target, bfname)
                break
        else:
            bfname = "{0}.backup".format(target)
            log.warning("Overwriting {0}".format(bfname))
            if not self.dryrun:
                self.rename(target, bfname)
        return bfname

    def merge(self, source, target):
        """Merge a target directory with a source tree"""

        if os.path.realpath(target) == os.path.realpath(source):
            log.info("Skipping merge for {0}, it already points to {1}".format(target, os.path.basename(source)))
            return

        log.info("Merging {0}".format(os.path.basename(source)))
        bfname = self.backup(target)

        self.symlink(source, target)

        log.debug("cp -r {0} {1}".format(bfname, target))
        if not self.dryrun:
            for dirpath, dirnames, filenames in os.walk(bfname):
                for filename in filenames:
                    filepath = join(dirpath, filename)

                    targetpath = join(target, os.path.relpath(filepath, bfname))

                    try:
                        os.makedirs(os.path.dirname(targetpath))
                    except OSError:
                        pass

                    shutil.copy2(filepath, targetpath)


def install_zprezto(home, dryrun=False):
    home = os.path.expanduser(home)
    destination = join(os.environ.get("ZDOTDIR", home), ".zprezto")

    if os.path.exists(destination):
        log.debug("Skipping .zprezto installation, {0} exists".format(destination))
        return

    command = ["git", "clone", "--recursive", "https://github.com/sorin-ionescu/prezto.git", destination]
    log.debug(" ".join(command))
    if not dryrun:
        subprocess.check_call(command)


def main():
    """Main function."""
    parser = argparse.ArgumentParser()
    parser.add_argument("-d", "--dotfiles", default=os.getcwd())
    parser.add_argument("--no-prezto", dest="prezto", action="store_false", help="Install zprezto")
    parser.add_argument("--home", default=HOME)
    parser.add_argument(
        "--mode",
        default="i",
        help="Set installer mode: [s]kip, [S]kip all, [o]verwrite, [O]verwrite all, [b]ackup, [B]ackup all",
    )
    parser.add_argument("-n", "--dry-run", dest="dryrun", action="store_true")
    parser.add_argument("-v", "--verbose", action="count", default=0)

    opt = parser.parse_args()

    ll = logging.WARNING
    ll -= min(10 * opt.verbose, logging.WARNING)

    logging.basicConfig(level=ll, format="[%(levelname)s] %(message)s")

    if opt.prezto and not opt.dryrun:
        install_zprezto(home=opt.home)

    installer = Installer(os.path.expanduser(opt.dotfiles), opt.home, mode=opt.mode, dryrun=opt.dryrun)
    installer.run()


if __name__ == "__main__":
    main()