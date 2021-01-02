export CLICOLOR=1
export LSCOLORS=Gxfxcxdxbxegedabagacad
export LC_CTYPE=en_US.UTF-8 #required for Textmate Budles SVN
export LESSCHARSET=utf-8
export LESS="-R"

typeset -aU path
fpath=($DOTFILES/zsh/functions $fpath)
autoload -U $DOTFILES/zsh/functions/*(:t)

HISTFILE=~/.zsh_history
HISTSIZE=1000000
SAVEHIST=1000000

setopt LOCAL_TRAPS # allow functions to have local traps
setopt PROMPT_SUBST
setopt CORRECT
setopt COMPLETE_IN_WORD
setopt IGNORE_EOF

# don't expand aliases _before_ completion has finished
#   like: git comm-[tab]
setopt complete_aliases

zle -N newtab

bindkey '^[^[[D' backward-word
bindkey '^[^[[C' forward-word
bindkey '^[[5D' beginning-of-line
bindkey '^[[5C' end-of-line
bindkey '^[[3~' delete-char
bindkey '^[^N' newtab
bindkey '^?' backward-delete-char
