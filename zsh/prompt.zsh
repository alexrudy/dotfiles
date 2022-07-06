# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.

if [[ -f ~/.config/starship.toml ]] && command -v starship > /dev/null; then
    # Use starship for the prompt
    eval "$(starship init zsh)"
else
    zstyle ':prezto:load' pmodule 'prompt'
    [[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
fi
