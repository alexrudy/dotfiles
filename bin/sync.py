#!/usr/bin/env python3
"""
A tool for working with domino sessions from a local machine.

Run this script with `--help` to learn more.
"""

import sys
import shlex
import subprocess
import functools
import os.path
import textwrap
from collections.abc import MutableMapping
from pathlib import Path

import yaml
import click

DOMINO_ENABLED = True
try:
    from lib.dominolib import get_ssh, DominoError
except ImportError:
    DOMINO_ENABLED = False

__HERE__ = Path(__file__).parent
__PROG__ = Path(__file__).name
__CONFIG__ = Path(".{}.yml".format(Path(__file__).stem))


DEFAULT_EXCLUDES = [
    ".domino*",
    ".Trash*",
    "results/*",
    ".ipynb_checkpoints*",
    "dask-worker-space*",
    "data/*",
]

HOST_ARGS_DOCS = """When specifying HOST as more than just a host name, it
is useful to use the special argument `--` which lets the script know that
all of the following arguments belong to the host ssh command. For example:

\b
    {__PROG__} {__func__.__name__} -- ssh -p 49001 ubuntu@ec2-*.us-west-2.compute.amazonaws.com

To avoid including the full ssh command for each subcommand, store it in
your {__CONFIG__!s} file using the `box` subcommand.
"""

DOMINO_INSTALL_MSG = """Domino library not installed. Run

    pip install git+https://github.com/dominodatalab/python-domino.git

to use this command."""


def require_domino(f):
    """A decorator which asserts that the domino libraries were imported sucessfully."""

    @functools.wraps(f)
    def _wrapper(*args, **kwargs):
        if not DOMINO_ENABLED:
            click.echo(DOMINO_INSTALL_MSG, err=True)
            sys.exit(1)
        return f(*args, **kwargs)

    return _wrapper


def dedent_docstring(docstring):
    first, *rest = docstring.splitlines()
    rest = textwrap.dedent("\n".join(rest)).splitlines()
    return "\n".join((first, *rest))


class SafeDict(dict):
    def __missing__(self, key):
        return "{" + key + "}"


def host_arguments(f):
    """Add support for host arguments."""
    f.__doc__ = dedent_docstring(f.__doc__).format_map(
        SafeDict(__HOST__=HOST_ARGS_DOCS)
    )
    return click.argument("host", nargs=-1, callback=handle_ssh_arguments)(f)


def format_docstrings(f):
    """Add some basic formatting to docstrings"""
    f.__doc__ = dedent_docstring(f.__doc__).format_map(
        dict(__PROG__=__PROG__, __func__=f, __CONFIG__=__CONFIG__)
    )
    return f


class Config(MutableMapping):
    def __init__(self, data, filename=__CONFIG__):
        self.filename = filename
        self._data = data

    def __repr__(self):
        return f"Config({self._data!r}, filename={self.filename!s})"

    def _dotted_config_resolver(self, key, setdefault=True):
        """Resolves down to the last row in the config"""

        if setdefault:
            get = lambda fragment, key_part: fragment.setdefault(key_part, {})
        else:
            get = lambda fragment, key_part: fragment.get(key_part, {})

        *parts, terminal_key = key.split(".")
        fragment = self._data
        for part in parts:
            fragment = get(fragment, part)
        return fragment, terminal_key

    def __setitem__(self, key, value):
        fragment, terminal_key = self._dotted_config_resolver(key)
        fragment[terminal_key] = value

    def __getitem__(self, key):
        fragment, terminal_key = self._dotted_config_resolver(key, setdefault=False)
        return fragment[terminal_key]

    def __delitem__(self, key):
        fragment, terminal_key = self._dotted_config_resolver(key, setdefault=False)
        del fragment[terminal_key]
        # TODO: This should recursively delete empty parent keys?

    def __contains__(self, key):
        fragment, terminal_key = self._dotted_config_resolver(key, setdefault=False)
        return terminal_key in fragment

    def __iter__(self):
        return iter(self._data)

    def __len__(self):
        return len(self._data)

    def save(self, filename=None):
        """Save the configuration to disk."""
        if filename is None:
            filename = self.filename
        # Remove dry run, as we don't want to save that.
        self.pop("rsync.dry_run", None)

        with filename.open("w") as stream:
            yaml.dump(self._data, stream)
        click.echo(f"Saved configuration to {filename!s}")


def to_dir(path):
    """Ensure a path ends with a directory"""
    path = str(path).rstrip(os.path.sep)
    return path + os.path.sep


def handle_ssh_arguments(ctx, param, value):
    """Handle SSH host arguments"""
    # pylint: disable=unused-argument
    if not value or ctx.resilient_parsing:
        default = ctx.obj.get("remote.ssh.host", "*")
        return default
    cfg = ctx.obj
    *ssh_arguments, host = value
    cfg["remote.ssh.host"] = host
    cfg["remote.ssh.args"] = list(ssh_arguments)
    return host if host != "*" else None


def rsync(cfg, src, dst):
    """Call rsync, using settings saved in the configuration."""

    rsync_command = ["rsync"]
    rsync_command.extend(cfg.get("rsync.options", ["-a", "-v", "-P", "-z", "-u"]))

    ssh_command = " ".join(cfg.get("remote.ssh.args", ["ssh"]))
    rsync_command.append(f"-e {ssh_command}")

    if cfg.get("rsync.dry_run", False):
        rsync_command.append("-n")

    excludes = cfg.get("rsync.excludes", [])
    rsync_command.extend((f"--exclude={pattern}" for pattern in excludes))

    rsync_command.extend((to_dir(path) for path in (src, dst)))
    return call(rsync_command)


def setup_configuration(ctx, param, value):
    # pylint: disable=unused-argument
    if not value or ctx.resilient_parsing:
        return
    config_file = Path(value)
    if config_file.exists():
        with config_file.open("r") as stream:
            ctx.obj.update(yaml.load(stream))
    ctx.obj.filename = config_file


def ensure_host_configured(f):
    """Ensure that this configuration has been set up."""

    @click.pass_obj
    @functools.wraps(f)
    def _wrapper(cfg, *args, **kwargs):
        if cfg.get("remote.ssh.host", "*") == "*":
            click.echo(
                f"{click.style('ERROR', fg='red')}: No configuration found at {cfg.filename!s}"
            )
            raise click.BadParameter(message="Host not specified")
        if not cfg.filename.exists():
            click.echo(
                f"{click.style('WARNING', fg='yellow')}: No configuration found at {cfg.filename!s}"
            )
        return f(cfg, *args, **kwargs)

    return _wrapper


def call(args):
    rc = subprocess.run(args).returncode
    if rc:
        sys.exit(rc)


def build_remote_command(working_directory, args, post_command=""):
    """
    These machinations ensure that the command is run
    (a) in the project working directory
    (b) using an 'interactive' shell, which ensures
    that .bashrc is read and loaded, as that is how
    domino propogates environment variables (ugh)
    """

    remote_cmd = "$SHELL -i -c 'cd {!s}; {!s}{}{}'".format(
        working_directory,
        " ".join(shlex.quote(arg) if arg != ";" else arg for arg in args),
        ";" if post_command else "",
        post_command,
    )
    return remote_cmd


@click.group()
@format_docstrings
@click.pass_obj
@click.option(
    "-c",
    "--config",
    default=__CONFIG__,
    type=click.Path(),
    callback=setup_configuration,
    expose_value=False,
    help="Path to the config file.",
)
@click.option("-n", "--dry-run", is_flag=True, default=False, help="Dry run rsync")
def main(cfg, dry_run):
    """Work with domino compute nodes from your local machine.

    To work with files in a domino project locally, you need
    to either mount the domino directory on your machine (not yet
    supported by this script) or copy files back and forth.
    This script manages that copy back-and-forth using rsync,
    and a configuration file in the directory you are syncing with domino.

    This tool relies on a configuration file, `{__CONFIG__!s}`, which
    you can create with the `init` command. All of the subcommands
    for this tool will accept the full ssh command string from
    domino (something like `ssh -p 49001 ubuntu@ec2-*.us-west-2.compute.amazonaws.com`).
    You can cache this string using the `box` subcommand, which
    'boxes' up your connection string and adds it to the
    configuration file (`{__CONFIG__!s}`) for later use. Unfortunately,
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
    cfg["rsync.dry_run"] = dry_run


@main.command()
@format_docstrings
@click.pass_obj
@click.option("-p", "--project", prompt=True, help="Project name")
def init(cfg, project):
    """Initialize a domino sync configuration.

    Configurations are stored in `{__CONFIG__!s}` files in
    your project directory. Run this command to make
    a basic configuration file, suitable for customization
    later."""
    excludes = cfg.setdefault("rsync.excludes", [])
    for exclude in DEFAULT_EXCLUDES:
        if exclude not in excludes:
            excludes.append(exclude)
    cfg.setdefault("project.name", f"even/{project}")
    cfg.setdefault("remote.path", f"/mnt/even/{project}/")
    cfg.save()


@main.command()
@format_docstrings
@click.pass_obj
@host_arguments
def box(cfg, host):
    """Cache the ssh host information.

    This command saves the ssh host and arguments to the
    {__CONFIG__!s} file for later use. If you haven't yet created
    a {__CONFIG__!s} file, you can do so via the {__PROG__} init
    command.

    {__HOST__}
    """
    # pylint: disable=unused-argument
    click.echo(
        "{}: {} {}".format(
            click.style("HOST", fg="green"),
            " ".join(cfg.get("remote.ssh.args", ["ssh"])),
            cfg.get("remote.ssh.host", "*"),
        )
    )
    cfg.save()


@main.command()
@format_docstrings
@click.pass_obj
@require_domino
def autobox(cfg):
    """Cache ssh host for current Domino run.

    This command looks up the latest currently active run for the project
    in Domino fetches its SSH information, then saves the ssh host and
    arguments to the {__CONFIG__!s} file for later use. If you haven't yet
    created a {__CONFIG__!s} file, you can do so via the {__PROG__} init command.

    For this function to work, two environment variables must be set:

        - DOMINO_API_HOST = https://app.dominodatalab.com

        - DOMINO_USER_API_KEY = a key which you generate at https://app.dominodatalab.com/account#api-keys

    And you must have the Domino python bindings installed:

        pip install git+https://github.com/dominodatalab/python-domino.git

    """
    project = cfg["project.name"]
    try:
        ssh_string = get_ssh(project).split()
    except DominoError as e:
        click.echo(f"Failed to look up SSH information: {e}", err=True)
        return

    *ssh_arguments, host = ssh_string
    cfg["remote.ssh.args"] = ssh_arguments
    cfg["remote.ssh.host"] = host

    click.echo(
        "{}: {} {}".format(
            click.style("HOST", fg="green"),
            " ".join(cfg.get("remote.ssh.args", ["ssh"])),
            cfg.get("remote.ssh.host", "*"),
        )
    )
    cfg.save()


@main.command()
@format_docstrings
@ensure_host_configured
@host_arguments
def up(cfg, host):
    """Move files up to domino.

    Uses rsync in archive and update mode (-au) to push only
    files changed locally to the server .

    If this pushes too many files, consider adding paths to the list
    of excludes in the {__CONFIG__!s} file for this project.

    {__HOST__}
    """
    source = Path.cwd()
    destination_path = cfg.get("remote.path", "/mnt/even/analytics/")
    destination = f"{host:s}:{destination_path}"

    return rsync(cfg, source, destination)


@main.command()
@format_docstrings
@ensure_host_configured
@host_arguments
def down(cfg, host):
    """Move files down from domino.

    Uses rsync in archive and update mode (-au) to pull only
    files changed on the server down to the local working directory.

    If this pulls too many files, consider adding paths to the list
    of excludes in the {__CONFIG__!s} file for this project.

    {__HOST__}
    """
    destination = Path.cwd()
    source_path = cfg.get("remote.path", "/mnt/even/analytics/")
    source = f"{host:s}:{source_path}"
    return rsync(cfg, source, destination)


@main.command()
@format_docstrings
@ensure_host_configured
@host_arguments
def ddd(cfg, host):
    """Dask dashboard port forwarder for domino.

    Once this is running and connected, you can open
    http://localhost:4487 in your webbrowser of choice
    to see the dask dashboard from your domino host.

    This requires the script `jt.py` be on your path,
    which is used for continuous, automatically restarted
    ssh connections.

    {__HOST__}
    """
    args = ["jt.py", "-p4487,8787", "--"]
    args.extend(cfg.get("remote.ssh.args", ["ssh"]))
    args.append(host)
    call(args)


@main.command()
@format_docstrings
@ensure_host_configured
@host_arguments
def ssh(cfg, host):
    """Open an ssh connection to domino.

    Opens a simple ssh connection to the domino machine.
    Mostly useful if you have saved your connection string
    via the `box` command.

    {__HOST__}
    """
    ssh_args = cfg.get("remote.ssh.args", ["ssh"])
    ssh_args.append(host)
    call(ssh_args)


@main.command()
@format_docstrings
@ensure_host_configured
@click.argument("cmd", nargs=-1)
def do(cfg, cmd):
    """Run a command on the remote host. For example:

    \b
        {__PROG__} do -- python myscript.py

    Pass the command after -- if it contains flags
    which might be interpreted as click options.
    """
    ssh_args = cfg.get("remote.ssh.args", ["ssh"])
    ssh_args.append("-t")  # force tty allocation
    ssh_args.append(cfg["remote.ssh.host"])

    remote_cmd = build_remote_command(cfg["remote.path"], cmd)
    ssh_args.append(remote_cmd)
    call(ssh_args)


@main.command()
@format_docstrings
@ensure_host_configured
@host_arguments
def push(cfg, host):
    """Push the current git branch to the remote machine. This works only
    if you are invoking {__PROG__} from within the even-server repo. This
    workflow works best if you are currently on a branch you use to develop
    even-server. You should commit your changes locally after you make them,
    then call {__PROG__} push to ensure that they are synced to your domino
    box.

    {__HOST__}
    """
    # pylint: disable=unused-argument
    branch = (
        subprocess.check_output(["git", "rev-parse", "--abbrev-ref", "HEAD"])
        .decode("utf-8")
        .strip()
    )
    click.echo(f"Updating branch {branch} on remote machine.")
    call(["git", "push", "origin", f"{branch}:{branch}"])

    # git-pull is implicitly a git-fetch then a git-merge, but we don't want to do that
    # if the remote isn't checked out into the correct branch.
    # The idea here is that we can always fetch (that doesn't touch the working tree)
    # but ONLY if we are on the correct branch can we merge.
    remote_git = ["git", "fetch", "origin", f"{branch}"]
    remote_git_check = (
        f"[[ $(git rev-parse --abbrev-ref HEAD) == {branch} ]] "
        f"&& git merge --ff-only origin/{branch}"
        f'|| echo "Warning: remote branch $(git rev-parse --abbrev-ref HEAD) '
        f'differs from local branch {branch}"'
    )

    remote_cmd = build_remote_command(
        cfg.get("repo.path", "/repos/even-server/"), remote_git, remote_git_check
    )
    ssh_args = cfg.get("remote.ssh.args", ["ssh"])
    ssh_args.append("-t")  # force tty allocation
    ssh_args.append(cfg["remote.ssh.host"])
    ssh_args.append(remote_cmd)
    call(ssh_args)


if __name__ == "__main__":
    main(
        obj=Config({})
    )  # pylint: disable=no-value-for-parameter,unexpected-keyword-arg
