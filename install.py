#!/usr/bin/env python
from __future__ import print_function
import glob
import os
import argparse
import sys
import warnings
import string

# Python2 fixes
if sys.version_info[0] < 3:
    input = raw_input


join = os.path.join

class _Getch:
    """Gets a single character from standard input.  Does not echo to the
screen."""
    def __init__(self):
        try:
            self.impl = _GetchWindows()
        except ImportError:
            self.impl = _GetchUnix()

    def __call__(self): return self.impl()


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
    
class Installer(object):
    """An installer, which asks questions of the user."""
    def __init__(self, mode="i", backup_check=1):
        super(Installer, self).__init__()
        self.mode = mode
        self._backup_check = backup_check
        
    def ask(self, target, kind="Dotfile"):
        """Ask about installing a particular item."""
        print("{0:s} already exists: {1:s}, what do you want to do?".format(kind, target))
        print("[s]kip, [S]kip all, [o]verwrite, [O]verwrite all, [b]ackup, [B]ackup all")
        ans = getch()
        c = ans[0]
        while c not in "sSoObB":
            if c in "qQ":
                raise SystemExit()
            print("Can't understand your input: {0}".format(ans))
            ans = getch()
            c = ans[0]
        self.mode = c
    
    def backup(self, target):
        """Backup a target."""
        bfname = target+".backup"
        for i in range(self._backup_check):
            if i:
                bfname = target+".backup{:d}".format(i)
            if not os.path.exists(bfname):
                os.rename(target, bfname)
                break
        else:
            warnings.warn("Overwriting {0}".format(bfname))
            os.rename(target, bfname)
    
    def _install(self, source, target, kind="Dotfile"):
        """Install a single file."""
        if os.path.exists(target):
            if self.mode == "i":
                self.ask(target, kind)
            if self.mode in "sS":
                return
            elif self.mode in "bB":
                self.backup(target)
            elif self.mode in "oO":
                warnings.warn("Overwriting {0}".format(target))
                os.remove(target)
            else:
                raise ValueError("Mode {0:s} is not understood.".format(self.mode))
        os.symlink(source, target)
        print("Linking {0}".format(os.path.basename(source)))
        return
    
    def install(self, dotfiles, home="~"):
        """Install from a shell glob."""
        home = os.path.expanduser(home)
        for filename in glob.iglob(join(dotfiles, "*", "*.symlink")):
            source = os.path.relpath(filename, home)
            target = join(home, ".{0:s}".format(os.path.splitext(os.path.basename(filename))[0]))
            
            prefix = os.path.commonpath(os.path.abspath(p) for p in (os.path.realpath(target), source))
            correct = os.path.abspath(dotfiles) in prefix
            
            if not (os.path.exists(target) and correct):
                self._install(source, target)
                
            if self.mode in string.ascii_lowercase:
                self.mode = "i"
        for dirname in glob.iglob(join(dotfiles, "*", "*.dir")):
            source = os.path.relpath(dirname, home)
            target = join(home, ".{0:s}".format(os.path.splitext(os.path.basename(dirname))[0]))
            
            prefix = os.path.commonpath(os.path.abspath(p) for p in (os.path.realpath(target), source))
            correct = os.path.abspath(dotfiles) in prefix
            
            if not (os.path.exists(target) and correct):
                self._install(source, target, kind="Directory")
            if self.mode in string.ascii_lowercase:
                self.mode = "i"

def main():
    """Main function."""
    parser = argparse.ArgumentParser()
    parser.add_argument("-d", "--dotfiles", default="~/.dotfiles")
    parser.add_argument("--home", default="~")
    opt = parser.parse_args()
    installer = Installer(mode="i")
    installer.install(os.path.expanduser(opt.dotfiles), opt.home)
    
if __name__ == '__main__':
    main()