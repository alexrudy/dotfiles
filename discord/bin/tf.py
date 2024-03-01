#!/home/discord/.virtualenvs/discord_ai/bin/python

from typing import Any
import click
import os
import subprocess
import contextlib


class ProjectNotFound(click.ClickException):
    def __init__(self, name: str, environment: str):
        self.name = name
        self.environment = environment
        self.exit_code = 127

    def __str__(self):
        return f"Could not find project {self.name} for environment {self.environment}"

    def show(self, file: Any = ...) -> None:
        click.echo(str(self), file=file)


@contextlib.contextmanager
def handle_subprocess_errors():
    try:
        yield
    except subprocess.CalledProcessError as e:
        emsg = click.style("ERROR", fg="red")
        click.echo(f"{emsg}: {e!s}", err=True)
        raise click.Abort()


@click.group()
def main():
    """CLI helpers for terraform-in-bazel"""


def terraform_apply_options(func) -> Any:
    click.option(
        "--upgrade/--no-upgrade",
        default=True,
        help="Whether to run terraform init with the -upgrade flag",
    )(func)
    click.option(
        "--init/--no-init",
        default=True,
        help="Whether to run terraform init before applying",
    )(func)
    click.option(
        "-e",
        "--env",
        "--environment",
        default="prd",
        help="The environment to apply the project to. Defaults to prd.",
    )(func)
    return func


@main.command()
@click.argument("project")
@terraform_apply_options
@handle_subprocess_errors()
def apply(
    project: str, env: str = None, init: bool = True, upgrade: bool = True
) -> None:
    """Apply a terraform project"""
    module = find_project(project, env)

    if init:
        if upgrade:
            args = (
                "init",
                "-upgrade",
            )
        else:
            args = ("init",)
        bzl(module, env, *args)

    bzl(module, env, "apply")


@main.command()
@click.argument("ucg")
@terraform_apply_options
@handle_subprocess_errors()
@click.pass_context
def ucg(
    ctx: click.Context,
    ucg: str,
    env: str = None,
    init: bool = True,
    upgrade: bool = True,
) -> None:
    """Apply terraform for a single data UCG."""
    project = f"discord-data-{ucg}"
    click.echo(
        "Applying {project} to {env}".format(
            project=click.style(project, bold=True), env=click.style(env, bold=True)
        )
    )
    ctx.invoke(apply, project=project, env=env, init=init, upgrade=upgrade)


@main.command(name="all-ucgs")
@terraform_apply_options
@handle_subprocess_errors()
@click.pass_context
def all_ucgs(
    ctx: click.Context, env: str = None, init: bool = True, upgrade: bool = True
) -> None:
    """Apply terraform for all data UCGs in sequence."""
    for ucg_name in ("analytics", "modeling", "reporting", "tns"):
        ctx.invoke(ucg, ucg=ucg_name, env=env, init=init, upgrade=upgrade)


def bzl(module: str, target: str, *args: str) -> None:
    if not (module.startswith("//") or module.startswith("@")):
        module = f"//{module}"

    command = ["bzl", "run", f"{module}:{target}", "--", *args]

    indicator = click.style(">", fg="blue", bold=True)
    args = click.style("bzl run", bold=True)
    args += " ".join(command[2:])
    click.echo(f"{indicator} {args}")

    subprocess.run(command, check=True)


def find_project(name: str, environment: str) -> str:
    if not name.startswith("discord-"):
        name = f"discord-{name}"

    default = f"discord-devops/terraform/{name}/{environment}"
    if os.path.isfile(os.path.join(default, "BUILD")):
        return default

    data = f"discord_devops/terraform/data/{name}/{environment}"
    if os.path.isfile(os.path.join(data, "BUILD")):
        return data

    raise ProjectNotFound(name, environment)


if __name__ == "__main__":
    main()
