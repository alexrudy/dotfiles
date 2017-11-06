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
@click.option("--role", default='user_engineer_default', type=str)
@click.option("--config", "config_path", default=os.path.expanduser('~/.aws/credentials'), type=click.Path())
def main(profile, role, config_path):
    """Update AWS credentials from the LendUp Vault"""
    if not check_vpn():
        click.echo("Please connect to the prod-us-east VPN before continuing")
        raise click.Abort()
        
    response_data = get_vault_info(role=role)
    config = get_aws_config(config_path)
    config[profile]['aws_access_key_id'] = response_data['access_key']
    config[profile]['aws_secret_access_key'] = response_data['secret_key']
    
    with open(config_path, 'w') as f:
        config.write(f)

def get_vault_info(role):
    """Get and parse fixed-width format Vault information."""
    out = subprocess.check_output(['vault', 'read', '--format', 'json', f'aws/creds/{role}'])
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