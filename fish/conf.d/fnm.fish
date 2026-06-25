# FNM
if test -e ~/.local/share/fnm/fnm
    fish_add_path -a ~/.local/share/fnm
    fnm env --use-on-cd --shell fish | source
end
