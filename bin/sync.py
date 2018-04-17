#!/usr/bin/env python3

import click
import subprocess
import yaml
import os.path
from pathlib import Path

__HERE__ = Path(__file__).parent

DEFAULT_EXCLUDES = [
    '.domino*', '.Trash*', 'results/*', '.ipynb_checkpoints*', 'dask-worker-space*'
]

def to_dir(path):
    """Ensure a path ends with a directory"""
    path = str(path).rstrip(os.path.sep)
    return path + os.path.sep
    
def handle_ssh_arguments(ctx, param, value):
    """Handle SSH host arguments"""
    if not value or ctx.resilient_parsing:
        default = ctx.obj.get('remote', {}).get('ssh', {}).get('host', '*')
        return default
    cfg = ctx.obj
    *ssh_arguments, host = value
    ssh = cfg.setdefault('remote', {}).setdefault('ssh', {})
    ssh['args'] = list(ssh_arguments)
    ssh['host'] = host
    return host

@click.group()
@click.pass_obj
@click.option('-c', '--config', default='.sync.yml', type=click.Path(), help='Path to the config file.')
@click.option('-n', '--dry-run', is_flag=True, default=False, help="Dry run rsync")
def main(cfg, config, dry_run):
    """Sync files back and forth from domino"""
    config = Path(config)
    if config.exists():
        with config.open("r") as stream:
            cfg.update(yaml.load(stream))
    else:
        click.secho(f"WARNING: No configuration found at {config!s}", fg='yellow')
    cfg.setdefault('rsync', {})['dry_run'] = dry_run
    

def rsync(cfg, src, dst):
    ssh_command = ' '.join(cfg.get('remote', {}).get('ssh', {}).get('args', ['ssh']))
    
    excludes = cfg.get('rsync', {}).get('excludes', [])
    
    rsync_command = ['rsync']
    rsync_command.extend(cfg.get('rsync', {}).get('options', ['-a', '-v', '-P', '-z', '-u']))
    rsync_command.append(f'-e {ssh_command}')
    
    if cfg.get('rsync', {}).get('dry_run', True):
        rsync_command.append('-n')
    
    rsync_command.extend((f'--exclude={pattern}' for pattern in excludes))
    
    rsync_command.extend([f"{to_dir(src)}", f"{to_dir(dst)}"])
    subprocess.check_call(rsync_command)

@main.command()
@click.option("-p", "--project", help='Project name')
def init(cfg, project_name):
    """Initialize a domino repo sync object."""
    rsync = cfg.setdefault('rsync', {})
    excludes = rsync.setdefault('excludes', [])
    for exclude in DEFAULT_EXCLUDES:
        if exclude not in excludes:
            excludes.append(exclude)
    remote = cfg.setdefault('remote', {})
    path = remote.setdefault('path', f'/mnt/even/{project_name}/')
    save_config(cfg)
    
@main.command()
@click.pass_obj
@click.argument('host', nargs=-1, callback=handle_ssh_arguments)
def box(cfg, host):
    """Record the appropriate ssh host information."""
    remote = cfg.setdefault('remote', {})
    ssh = remote.setdefault('ssh', {})
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
    """Sync up to domino"""
    source = Path.cwd()
    destination_path = cfg.get('remote', {}).get('path', '/mnt/even/analytics')
    destination = f"{host:s}:{destination_path}"
    
    rsync(cfg, source, destination)
    
@main.command()
@click.pass_obj
@click.argument('host', nargs=-1, callback=handle_ssh_arguments)
def down(cfg, host):
    """Sync down from domino"""
    
    destination = Path.cwd()
    source_path = cfg.get('remote', {}).get('path', '/mnt/even/analytics')
    source = f"{host:s}:{source_path}"
    
    rsync(cfg, source, destination)
    
@main.command()
@click.pass_obj
@click.argument('host', nargs=-1, callback=handle_ssh_arguments)
def ddd(cfg, host):
    """Launch the dask dashboard port forwarder."""
    args = ['jt.py', '-p4487,8787', '--']
    args.extend(cfg.get('remote', {}).get('ssh', {}).get('args', []))
    args.append(host)
    subprocess.check_call(args)
    
    

if __name__ == '__main__':
    main(obj={})
