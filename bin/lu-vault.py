#!/usr/bin/env python3

import click
import subprocess
import configparser
import os
import posixpath
import json
import io

TB_SCRIPT = """
tell application "Tunnelblick"
	set connected_configs to name of every configuration whose state = "CONNECTED"
	return connected_configs
end tell
"""

@click.command()
@click.option("--auth/--no-auth", default=True, is_flag=True, help="Authenticate with vault first.")
@click.option("--profile", default='default', type=str, help='AWS profile to update')
@click.option("--og", is_flag=True, help="Use OG method.")
@click.option("--from-profile/--not-from-profile", default=True, is_flag=True, help="Gather arguments from the aws profile.")
@click.option("--vault-path", default='aws/creds', type=str, help="Default path in the vault for keys.")
@click.option("--vault-write/--vault-read", default=True, is_flag=True, help="Should we read or write from the vault?")
@click.option("--role", "--vault-role", default='user_engineer_default', type=str)
@click.option("--config", "config_path", default=os.path.expanduser('~/.aws/credentials'), type=click.Path())
@click.option("--vault-username", default=os.environ['USER'])
def main(auth, profile, og, from_profile, vault_path, vault_write, vault_role, config_path, vault_username):
    """Update AWS credentials from the LendUp Vault"""
    if not check_vpn():
        click.echo("Please connect to the prod-us-east VPN before continuing")
        raise click.Abort()
    if not check_vault_connection():
        if auth:
            authenticate_vault(vault_username)
        else:
            click.echo("Please authenticate in vault with `vault auth` or the `--auth` flag to this command.")
            raise click.Abort()

    config = get_aws_config(config_path)

    if from_profile and profile in config:
        vault_role = config[profile].get('vault_role', vault_role)
        vault_path = config[profile].get('vault_path', vault_path)
        vault_write = config[profile].getboolean('vault_write', vault_write)

    if og:
        vault_path = "aws/sts"
        vault_write = True
        if not vault_role.endswith('-og'):
            vault_role += '-og'

    try:
        response_data = get_vault_info(path=vault_path, role=vault_role, write=vault_write)
    except subprocess.CalledProcessError as e:
        click.echo("Error in vault read, returned exit code: {}".format(e.returncode))
        raise click.Abort()
    if profile not in config:
        config.add_section(profile)

    if from_profile:
        config[profile]['vault_role'] = vault_role
        config[profile]['vault_path'] = vault_path
        config[profile]['vault_write'] = "yes" if vault_write else "no"

    config[profile]['aws_access_key_id'] = response_data['access_key']
    config[profile]['aws_secret_access_key'] = response_data['secret_key']
    if response_data.get('security_token', False):
        config[profile]['aws_session_token'] = response_data['security_token']
    elif 'aws_session_token' in config[profile]:
        config[profile].pop('aws_session_token')

    with open(config_path, 'w') as f:
        config.write(f)

def get_vault_info(path, role, write):
    """Get and parse fixed-width format Vault information."""
    fullpath = posixpath.join(path, role)
    if write:
        out = subprocess.check_output(['vault', 'write', '-f', '--format', 'json', f'{fullpath}'])
    else:
        out = subprocess.check_output(['vault', 'read', '--format', 'json', f'{fullpath}'])
    response = json.loads(out)
    return response['data']

def check_vault_connection():
    """docstring for check_vault_connection"""
    try:
        out = subprocess.check_output(['vault', 'read', '--format', 'json', '/auth/token/lookup-self']) == 0
    except subprocess.CalledProcessError as e:
        return False
    else:
        return True

def authenticate_vault(username):
    """Authenticate to Vault."""
    args = ['vault', 'auth', '-method=ldap', 'username={}'.format(username)]
    click.echo(" ".join(args))
    subprocess.call(args)

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
