#!/home/discord/.virtualenvs/discord_ai/bin/python

from typing import Any, Callable, Optional, TypeVar, Union, IO, Iterator
import concurrent.futures
import click
import os
import subprocess
import contextlib
import glob

class ProjectNotFound(click.ClickException):
    def __init__(self, name: str, environment: str):
        self.name = name
        self.environment = environment
        self.exit_code = 127

    def __str__(self):
        return f"Could not find project {self.name} for environment {self.environment}"

    def show(self, file: Optional[IO[str]] = None) -> None:
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


@click.group(invoke_without_command=True, context_settings=dict(
    ignore_unknown_options=True,
    allow_extra_args=True,
))
@click.pass_context
def main(ctx: click.Context):
    """Helpers for terraform at discord"""


def terraform_apply_options(plan: bool = False) -> Any:
    def _decorator(func) -> Any:
        click.option(
            "--upgrade/--no-upgrade",
            default=True,
            help="Whether to run terraform init with the -upgrade flag",
        )(func)
        click.option(
            "--init",
            "init",
            flag_value='init',
            help="Run terraform init before applying",
        )(func)
        click.option(
            "--no-init",
            "init",
            flag_value='no-init',
            help="Do not terraform init before applying",
        )(func)
        click.option(
            "--auto-init",
            "init",
            flag_value='auto-init',
            help="Detect whether terraform init has run for this project, and only run it if necessary",
            default=True
        )(func)
        if not plan:
            click.option(
                "--plan/--apply", default=plan, is_flag=True, help="Run plan, not apply"
            )(func)
        return func

    return _decorator


T = TypeVar("T")


def tf_env_option() -> Callable[[T], T]:
    return click.option(
        "-e",
        "--env",
        "--environment",
        default="prd",
        envvar="ENV",
        help="The environment to apply the project to. Defaults to prd.",
    )


@main.command(context_settings=dict(
    ignore_unknown_options=True,
    allow_extra_args=True,
))
@click.argument("project")
@tf_env_option()
@handle_subprocess_errors()
@click.pass_context
def run(ctx: click.Context, project: str, env: str) -> None:
    """Run a terraform command"""
    module = find_project(project, env)
    bzl_run_tf(module, env, *ctx.args)


@main.command()
@click.argument("project")
@click.argument("targets", type=click.File())
@click.option("-n", "--dry-run", is_flag=True, default=False)
@tf_env_option()
@handle_subprocess_errors()
def rm(project: str, env: str, targets: IO[str], dry_run: bool) -> None:
    """Remove state listed in a file"""
    module = find_project(project, env)


    args = ['state', 'rm']
    if dry_run:
        args.append("-dry-run")


    for line in targets:
        args.append(line.strip())

    bzl_run_tf(module, env, *args)



@main.command()
@click.argument("project")
@tf_env_option()
@terraform_apply_options()
@handle_subprocess_errors()
def apply(
    project: str, env: str, init: str = 'auto-init', upgrade: bool = True, plan: bool = False
) -> None:
    """Apply a terraform project"""
    module = find_project(project, env)

    if (init == 'init') or (init == 'auto-init' and not is_module_init(module)):
        args = ["init"]
        if upgrade:
            args += ["-upgrade"]

        bzl_run_tf(module, env, *args)

    if plan:
        bzl_run_tf(module, env, "plan")
    else:
        bzl_run_tf(module, env, "apply")


@main.command()
@click.argument("project")
@tf_env_option()
@terraform_apply_options(plan=True)
@handle_subprocess_errors()
@click.pass_context
def plan(
    ctx: click.Context,
    project: str,
    env: str,
    init: bool = True,
    upgrade: bool = True,
    plan: bool = True,
) -> None:
    """Plan a terraform project"""
    if not plan:
        click.echo("The plan command is a no-op when --apply is passed")
        return

    ctx.invoke(apply, project=project, env=env, init=init, upgrade=upgrade, plan=plan)


@main.command()
@click.argument("ucg")
@tf_env_option()
@terraform_apply_options()
@handle_subprocess_errors()
@click.pass_context
def pada(
    ctx: click.Context,
    ucg: str,
    env: str,
    init: bool = True,
    upgrade: bool = True,
    plan: bool = False,
) -> None:
    """Apply terraform for a single data PADA UCG."""
    project = f"discord-pada-{ucg}"
    click.echo(
        "Applying {project} to {env}".format(
            project=click.style(project, bold=True), env=click.style(env, bold=True)
        ),
        err=True
    )
    ctx.invoke(apply, project=project, env=env, init=init, upgrade=upgrade, plan=plan)


@main.command(name="all-pada")
@tf_env_option()
@terraform_apply_options()
@handle_subprocess_errors()
@click.pass_context
def all_pada(
    ctx: click.Context,
    env: str,
    init: bool = True,
    upgrade: bool = True,
    plan: bool = False,
    vault: bool = False
) -> None:
    """Apply terraform for all PADA UCGs."""
    for ucg_name in list_pada_ucgs():
        if not vault and ucg_name == "discord-pada-vault":
            continue
        ctx.invoke(ucg, ucg=ucg_name, env=env, init=init, upgrade=upgrade, plan=plan)


@main.command()
@click.argument("ucg")
@tf_env_option()
@terraform_apply_options()
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
        ),
        err=True
    )
    ctx.invoke(apply, project=project, env=env, init=init, upgrade=upgrade, plan=plan)


@main.command(name="all-ucgs")
@tf_env_option()
@terraform_apply_options()
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
    click.echo(f"{indicator} {cmd}", err=True)
    return subprocess.run(command, **options)


def is_module_init(path: str) -> bool:

    # Strip bazel module prefix
    if path.startswith("//"):
        path = path[2:]

    # Consider bazel repos as uninit always
    if path.startswith("@"):
        return False

    home = os.environ["HOME"]
    state = os.path.join(home, ".terraform", "bazel", path)

    candidates = ("terraform.tfstate", os.path.join("providers", "registry.terraform.io"), os.path.join("modules", "modules.json"))

    if any(os.path.exists(os.path.join(state, c)) for c in candidates):
        return True
    return False


def is_bazel_target(path: str) -> bool:
    if os.path.exists(os.path.join(path, "BUILD")):
        return True
    if os.path.exists(os.path.join(path, "BUILD.bazel")):
        return True
    return False

def trim_pada_path(path: str) -> str:
    return "-".join(os.path.basename(path).split("-")[2:])

def list_pada_ucgs() -> Iterator[str]:
    base = "discord_devops/terraform/data/discord-pada-*"
    return (trim_pada_path(path) for path in glob.iglob(base))


def find_project(name: str, environment: str) -> str:
    if not name.startswith("discord-"):
        full_name = f"discord-{name}"

    default = f"discord_devops/terraform/{full_name}/{environment}"
    if is_bazel_target(default):
        return default

    data = f"discord_devops/terraform/data/{full_name}/{environment}"
    if is_bazel_target(data):
        return data

    if "pada" in name:
        data = f"discord_devops/terraform/data/{full_name}/{environment}"
        if is_bazel_target(data):
            return data



    if name in set(list_pada_ucgs()):
        data = f"discord_devops/terraform/data/discord-pada-{name}"
        if is_bazel_target(data):
            return data

    raise ProjectNotFound(name, environment)


if __name__ == "__main__":
    main()
