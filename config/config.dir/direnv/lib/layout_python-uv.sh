# Usage: layout python-uv
#
# Enables the uv project layout in the current directory, and syncs
# the dependencies in the project.
#
# This relies on the `uv` command being available in the PATH, and performs a
# sync on cd because uv is fast enough it's not impactful. It relies on uv's
# configuration file and environment variables, rather than arguments.
#
layout_python-uv() {
  # Watch the uv configuration file for changes
  watch_file .python-version pyproject.toml uv.lock

  # activate the virtualenv after syncing; this puts the newly-installed
  # binaries on PATH.
  venv_path="$(expand_path "${UV_PROJECT_ENVIRONMENT:-.venv}")"
  if [[ -e $venv_path ]]; then
    # shellcheck source=/dev/null
    source "$venv_path/bin/activate"
  fi

}
