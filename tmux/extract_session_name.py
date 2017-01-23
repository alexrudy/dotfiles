#!/usr/bin/env python

from __future__ import print_function
import yaml
import sys

def main():
    """docstring for main"""
    with open(sys.argv[1], 'r') as f:
        config = yaml.load(f)
    try:
        print(config['session_name'], end='')
    except KeyError:
        pass
    
if __name__ == '__main__':
    main()
