#!/home/discord/.virtualenvs/discord_ai/bin/python

from typing import Any, Callable, TypeVar, Union
import concurrent.futures
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
        if e.stdout:
            click.echo("stdout:")
            click.echo()
            show_stream(e.stdout)
            click.echo()
        if e.stderr:
            click.echo("stderr:")
            click.echo()
            show_stream(e.stderr)
            click.echo()
        raise click.Abort()


def show_stream(stream: Union[str, bytes]) -> None:
    if not stream:
        return
    if isinstance(stream, str):
        click.echo(stream)
    else:
        click.echo(stream.decode("utf-8"))


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
        "--plan/--apply", default=False, is_flag=True, help="Run plan, not apply"
    )(func)
    return func


T = TypeVar("T")


def tf_env_option() -> Callable[[T], T]:
    return click.option(
        "-e",
        "--env",
        "--environment",
        default="prd",
        help="The environment to apply the project to. Defaults to prd.",
    )


@main.command()
@click.argument("project")
@tf_env_option()
@terraform_apply_options
@handle_subprocess_errors()
def apply(
    project: str, env: str, init: bool = True, upgrade: bool = True, plan: bool = False
) -> None:
    """Apply a terraform project"""
    module = find_project(project, env)

    if init:
        args = ["init"]
        if upgrade:
            args += ["-upgrade"]

        bzl_run_tf(module, env, *args)

    if plan:
        bzl_run_tf(module, env, "plan")
    else:
        bzl_run_tf(module, env, "apply")


@main.command()
@click.argument("ucg")
@tf_env_option()
@terraform_apply_options
@handle_subprocess_errors()
@click.pass_context
def ucg(
    ctx: click.Context,
    ucg: str,
    env: str,
    init: bool = True,
    upgrade: bool = True,
    plan: bool = False,
) -> None:
    """Apply terraform for a single data UCG."""
    project = f"discord-data-{ucg}"
    click.echo(
        "Applying {project} to {env}".format(
            project=click.style(project, bold=True), env=click.style(env, bold=True)
        )
    )
    ctx.invoke(apply, project=project, env=env, init=init, upgrade=upgrade, plan=plan)


@main.command(name="all-ucgs")
@tf_env_option()
@terraform_apply_options
@handle_subprocess_errors()
@click.pass_context
def all_ucgs(
    ctx: click.Context,
    env: str,
    init: bool = True,
    upgrade: bool = True,
    plan: bool = False,
) -> None:
    """Apply terraform for all data UCGs in sequence."""
    for ucg_name in ("analytics", "modeling", "reporting", "tns"):
        ctx.invoke(ucg, ucg=ucg_name, env=env, init=init, upgrade=upgrade, plan=plan)


@main.command()
@click.argument("project")
@handle_subprocess_errors()
def lint(project: str) -> None:
    """Lint some terraform"""

    if "data" in project:
        queries = [
            "//discord_devops/terraform/modules/data/...",
            "//discord_devops/terraform/data/...",
        ]
    else:
        queries = [f"//discord_devops/terraform/{project}/..."]
        modules = f"/discord_devops/terraform/modules/{project}"
        if os.path.isdir(modules):
            queries.append(f"/{modules}/...")

    procs = [
        bzl(
            "query",
            f"kind('_tf_module', {query})",
            "--output=label",
            capture_output=True,
            text=True,
        )
        for query in queries
    ]
    with concurrent.futures.ThreadPoolExecutor(max_workers=5) as pool:
        linters = {}
        for proc in procs:
            for line in proc.stdout.splitlines():
                label = line.strip()
                if "/execution-projects/discord-data-bqexec" in label:
                    continue
                if label not in linters:
                    linters[label] = pool.submit(bzl_lint, label, capture_output=True)
        for fut in concurrent.futures.as_completed(linters.values(), timeout=600):
            fut.result(timeout=0.1)

    click.echo("DONE!")


def bzl_lint(label, **options: Any) -> None:
    bzl("run", f"{label}.lint", **options)


def bzl_run_tf(module: str, target: str, *args: str) -> None:
    if not (module.startswith("//") or module.startswith("@")):
        module = f"//{module}"
    bzl("run", f"{module}:{target}", "--", *args)


def bzl(*args: str, **options: Any) -> subprocess.CompletedProcess:
    options.setdefault("check", True)
    command = ["bzl", *args]
    indicator = click.style(">", fg="blue", bold=True)
    cmd = click.style(" ".join(command[:2]), bold=True)
    if len(command) > 2:
        cmd += " "
        cmd += " ".join(command[2:])
    click.echo(f"{indicator} {cmd}")
    return subprocess.run(command, **options)


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
