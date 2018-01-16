#!/usr/bin/env python3

import click
import subprocess
import configparser
import os
import json
import io

TB_SCRIPT = """
tell application "Tunnelblick"
	set connected_configs to name of every configuration whose state = "CONNECTED"
	return connected_configs
end tell
"""

@click.command()
@click.option("--profile", default='default', type=str, help='AWS profile to update')
@click.option("--vault-path", default='aws/creds', type=str, help="Default path in the vault for keys.")
@click.option("--vault-write/--vault-read", default=True, is_flag=True, help="Should we read or write from the vault?")
@click.option("--role", "--vault-role", default='user_engineer_default', type=str)
@click.option("--config", "config_path", default=os.path.expanduser('~/.aws/credentials'), type=click.Path())
def main(profile, vault_path, vault_write, vault_role, config_path):
    """Update AWS credentials from the LendUp Vault"""
    if not check_vpn():
        click.echo("Please connect to the prod-us-east VPN before continuing")
        raise click.Abort()
        
    try:
        response_data = get_vault_info(path=vault_path, role=vault_role, write=vault_write)
    except subprocess.CalledProcessError as e:
        click.echo("Error in vault read, returned exit code: {}".format(e.returncode))
        raise click.Abort()
    config = get_aws_config(config_path)
    if profile not in config:
        config.add_section(profile)
    
    config[profile]['aws_access_key_id'] = response_data['access_key']
    config[profile]['aws_secret_access_key'] = response_data['secret_key']
    if 'security_token' in response_data:
        config[profile]['aws_session_token'] = response_data['security_token']
    else:
        config[profile].pop('aws_session_token')
    
    with open(config_path, 'w') as f:
        config.write(f)

def get_vault_info(path, role, write):
    """Get and parse fixed-width format Vault information."""
    if write:
        out = subprocess.check_output(['vault', 'write', '-f', '--format', 'json', f'{path}{role}'])
    else:
        out = subprocess.check_output(['vault', 'read', '--format', 'json', f'{path}{role}'])
    response = json.loads(out)
    return response['data']

def check_vpn(connection='prod-us-east'):
    """Check VPN Connection"""
    out = subprocess.check_output(["osascript", "-e", TB_SCRIPT]).decode('utf-8')
    return connection in out
    
def get_aws_config(path="~/.aws/credentials"):
    """Get the AWS configuration"""
    config = configparser.ConfigParser()
    config.read(path)
    return config
    
if __name__ == '__main__':
    main()