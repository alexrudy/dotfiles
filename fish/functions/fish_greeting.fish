function fish_greeting

    set_color blue
    fish --version

    set -l host_welcome ~/.config/fish/welcome/$(hostname).fish
    if test -f $host_welcome
        source $host_welcome
    end
    set_color normal

end
