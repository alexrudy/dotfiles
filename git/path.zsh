pathadd $DOTFILES/git/bin

export REVIEW_BASE=main

if command -v gh > /dev/null; then
  eval "$(gh completion -s zsh)"
  export GITHUB_TOKEN=$(gh auth token)
fi
