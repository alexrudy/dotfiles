if [ -f "/usr/local/share/zsh-completions" ]; then
fpath=(/usr/local/share/zsh-completions $fpath)
fi

if [ -f "/opt/homebrew/share/zsh-completions" ]; then
fpath=(/opt/homebrew/share/zsh-completions $fpath)
fi