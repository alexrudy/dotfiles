#!/usr/bin/env python3
import sys
import subprocess

def main():
    """Forward arguments to jt.py"""
    try:
        rc = subprocess.run(["jt.py", "-R", "-p", "52698"] + sys.argv[1:]).returncode
    except KeyboardInterrupt:
        rc = 0
    sys.exit(rc)

if __name__ == '__main__':
    main()