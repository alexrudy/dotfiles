#!/usr/bin/env python3

import click
import subprocess
import yaml
import os.path
from pathlib import Path

__HERE__ = Path(__file__).parent

def to_dir(path):
    """Ensure a path ends with a directory"""
    path = str(path).rstrip(os.path.sep)
    return path + os.path.sep
    

@click.group()
@click.pass_obj
def main(cfg):
    """Sync files back and forth from domino"""
    config = Path(".sync.yml")
    if config.exists():
        cfg.update(yaml.load(config.open("r")))
    else:
        click.secho("WARNING: No configuration found at .sync.yml", fg='yellow')

def rsync(cfg, src, dst, ssh_args, dry_run=False):
    ssh_command = ' '.join(ssh_args)
    
    excludes = cfg.get('rsync', {}).get('excludes', [])
    
    rsync_command = ['rsync', '-a', '-v', '-P', '-z', f'-e {ssh_command}']
    
    if dry_run:
        rsync_command.append('-n')
    
    rsync_command.extend((f'--exclude={pattern}' for pattern in excludes))
    
    rsync_command.extend([f"{to_dir(src)}", f"{to_dir(dst)}"])
    subprocess.check_call(rsync_command)
    
@main.command()
@click.pass_obj
@click.argument('host_args', nargs=-1)
def up(cfg, host_args):
    """Sync up to domino"""
    ssh_args = host_args[:-1]
    ssh_host = host_args[-1]
    
    source = Path.cwd()
    destination_path = cfg.get('remote', {}).get('path', '/mnt/even/analytics')
    destination = f"{ssh_host:s}:{destination_path}"
    
    rsync(cfg, source, destination, ssh_args)
    
@main.command()
@click.pass_obj
@click.argument('host_args', nargs=-1)
def down(cfg, host_args):
    """Sync down from domino"""
    ssh_args = host_args[:-1]
    ssh_host = host_args[-1]
    
    destination = Path.cwd()
    source_path = cfg.get('remote', {}).get('path', '/mnt/even/analytics')
    source = f"{ssh_host:s}:{source_path}"
    
    rsync(cfg, source, destination, ssh_args)
    
    

if __name__ == '__main__':
    main(obj={})
