#!/usr/bin/env python3
"""
A tool for working with domino sessions from a local machine.

This tool relies on a configuration file, `.sync.yml`, which
you can create with the `init` command. All of the subcommands
for this tool will accept the full ssh command string from
domino (something like `ssh -p 49001 ubuntu@ec2-*.us-west-2.compute.amazonaws.com`).
You can cache this string using the `box` subcommand, which
'boxes' up your connection string and adds it to the 
configuration file (`.sync.yml`) for later use. Unfortunately,
there does not seem to be a way to automatically discover the
ec2 address of the host machine for a given domino run 
programatically.

Commonly useful commands other than `init` and `box` are `up` and
`down`, which rsync files up to and down from domino respectively
using rsync to ensure that only changed files are moved. Also,
the `ssh` command will open an ssh connection and return the command
line to you. This is mostly useful if you've stored connection
info using `box`. Finally, `ddd` will open a persistent ssh connection
and set up port forwarding for the dask dashboard, which you can then
open in a webbrowser. This requires that you have the `jt.py` script
on your path as well as this script.
"""

import click
import subprocess
import yaml
import os.path
from pathlib import Path

__HERE__ = Path(__file__).parent

DEFAULT_EXCLUDES = [
    '.domino*', '.Trash*', 'results/*', '.ipynb_checkpoints*', 'dask-worker-space*'
]

def getcfg(cfg, key, default=None):
    """Get a key from a configuraiton, with a default value.
    
    Accepts keys with dotted values."""
    *parts, terminal_key = key.split(".")
    _cfg_part = cfg
    for part in parts:
        _cfg_part = _cfg_part.setdefault(part, {})
    return _cfg_part.setdefault(terminal_key, default)

def to_dir(path):
    """Ensure a path ends with a directory"""
    path = str(path).rstrip(os.path.sep)
    return path + os.path.sep
    
def handle_ssh_arguments(ctx, param, value):
    """Handle SSH host arguments"""
    if not value or ctx.resilient_parsing:
        default = getcfg(ctx.obj, 'remote.ssh.host', '*')
        return default
    cfg = ctx.obj
    *ssh_arguments, host = value
    ssh = getcfg(ctx.obj, 'remote.ssh', {})
    ssh['args'] = list(ssh_arguments)
    ssh['host'] = host
    return host

@click.group()
@click.pass_context
@click.pass_obj
@click.option('-c', '--config', default='.sync.yml', type=click.Path(), help='Path to the config file.')
@click.option('-n', '--dry-run', is_flag=True, default=False, help="Dry run rsync")
def main(cfg, ctx, config, dry_run):
    """Work with domino sessions from your local machine.
    
    To work with files in a domino project locally, you need
    to either mount the domino directory on your machine (not yet 
    supported by this script) or copy files back and forth (
    hence the `sync` name). This script manages that copy back-
    and-forth using rsync, and a configuration file in the directory
    you are syncing with domino.
    
    """
    config = Path(config)
    if config.exists():
        with config.open("r") as stream:
            cfg.update(yaml.load(stream))
    elif ctx.invoked_subcommand not in ('init',):
        click.echo(f"{click.style('WARNING', fg='yellow')}: No configuration found at {config!s}")
    getcfg(cfg, 'rsync', {})['dry_run'] = dry_run
    

def rsync(cfg, src, dst):
    """Call rsync, using settings saved in the configuration."""
    
    rsync_command = ['rsync']
    rsync_command.extend(getcfg(cfg, 'rsync.options', ['-a', '-v', '-P', '-z', '-u']))
    
    ssh_command = ' '.join(getcfg(cfg, 'remote.ssh.args', ['ssh']))
    rsync_command.append(f'-e {ssh_command}')
    
    if getcfg(cfg, 'rsync.dry_run', False):
        rsync_command.append('-n')
    
    excludes = getcfg(cfg, 'rsync.excludes', [])
    rsync_command.extend((f'--exclude={pattern}' for pattern in excludes))
    
    rsync_command.extend((to_dir(path) for path in (src, dst)))
    subprocess.check_call(rsync_command)

@main.command()
@click.option("-p", "--project", help='Project name')
def init(cfg, project_name):
    """Initialize a domino sync configuration.
    
    Configurations are stored in `.sync.yml` files in
    your project directory. Run this command to make
    a basic configuration file, suitable for customization
    later."""
    excludes = getcfg(cfg, 'rsync.excludes', [])
    for exclude in DEFAULT_EXCLUDES:
        if exclude not in excludes:
            excludes.append(exclude)
    getcfg(cfg, 'remote.path', f'/mnt/even/{project_name}/')
    save_config(cfg)
    
@main.command()
@click.pass_obj
@click.argument('host', nargs=-1, callback=handle_ssh_arguments)
def box(cfg, host):
    """Cache the ssh host information.
    
    This command saves the ssh host and arguments to the
    .sync.yml file for later use.
    """
    ssh = getcfg(cfg, 'remote.ssh', {})
    ssh.setdefault('args', list(host_args[:-1]))
    ssh['host'] = host_args[-1]
    save_config(cfg)
    
def save_config(cfg):
    """Save the configuration to disk."""
    config = Path(".sync.yml")
    with config.open('w') as stream:
        yaml.dump(cfg, stream)
    click.echo(f"Saved configuration to {config!s}")
    
@main.command()
@click.pass_obj
@click.argument('host', nargs=-1, callback=handle_ssh_arguments)
def up(cfg, host):
    """Push files up to domino
    
    Uses rsync in archive and update mode (-au) to push only
    files changed locally to the server .
    
    If this pushes too many files, consider adding paths to the list
    of excludes in the .sync.yml file for this project.
    
    """
    source = Path.cwd()
    destination_path = getcfg(cfg, 'remote.path', '/mnt/even/analytics/')
    destination = f"{host:s}:{destination_path}"
    
    rsync(cfg, source, destination)
    
@main.command()
@click.pass_obj
@click.argument('host', nargs=-1, callback=handle_ssh_arguments)
def down(cfg, host):
    """Pull files down from domino
    
    Uses rsync in archive and update mode (-au) to pull only
    files changed on the server down to the local working directory.
    
    If this pulls too many files, consider adding paths to the list
    of excludes in the .sync.yml file for this project.
    """
    destination = Path.cwd()
    source_path = getcfg(cfg, 'remote.path', '/mnt/even/analytics/')
    source = f"{host:s}:{source_path}"
    rsync(cfg, source, destination)
    
@main.command()
@click.pass_obj
@click.argument('host', nargs=-1, callback=handle_ssh_arguments)
def ddd(cfg, host):
    """Dask dashboard port forwarder for domino.
    
    Once this is running and connected, you can open
    http://localhost:4487 in your webbrowser of choice
    to see the dask dashboard from your domino host.
    
    This requires `jt.py` be on your path.
    
    """
    args = ['jt.py', '-p4487,8787', '--']
    args.extend(getcfg(cfg, 'remote.ssh.args', ['ssh']))
    args.append(host)
    subprocess.check_call(args)
    
@main.command()
@click.pass_obj
@click.argument('host', nargs=-1, callback=handle_ssh_arguments)
def ssh(cfg, host):
    """Open an ssh connection to domino.
    
    Opens a simple ssh connection to the domino machine.
    Mostly useful if you have saved your connection string
    via the `box` command.
    """
    ssh_args = getcfg(cfg, 'remote.ssh.args', ['ssh'])
    ssh_args.append(host)
    subprocess.check_call(ssh_args)

if __name__ == '__main__':
    main(obj={})
