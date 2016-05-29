#===============================================================
#
# ALIASES AND FUNCTIONS
#
#===============================================================

#-------------------
# Personnal Aliases
#-------------------

alias dotfiles='$EDITOR ~/.dotfiles'
alias sudo='sudo '
alias mkdir='mkdir -p'
alias h='history'
alias j='jobs -l'
alias ww='type -a'
alias ..='cd ..'
alias path='echo -e ${PATH//:/\\n}'
alias libpath='echo -e ${LD_LIBRARY_PATH//:/\\n}'

alias du='du -kh'       # Makes a more readable output.
alias df='df -kTh'
alias reload='source ~/.bash_profile'
alias lscreen='screen -dr'

#-------------------------------------------------------------
# The 'ls' family
#-------------------------------------------------------------
alias ll="ls -l"
alias ls='ls -hF'  # add colors for filetype recognition
alias la='ls -Al'          # show hidden files
alias lx='ls -lXB'         # sort by extension
alias lk='ls -lSr'         # sort by size, biggest last
alias lc='ls -ltcr'        # sort by and show change time, most recent last
alias lu='ls -ltur'        # sort by and show access time, most recent last
alias lt='ls -ltr'         # sort by date, most recent last
alias lm='ls -al | less'   # pipe through 'more'
alias lr='ls -lR'          # recursive ls
alias tree='tree -Csu'     # nice alternative to 'recursive ls'
