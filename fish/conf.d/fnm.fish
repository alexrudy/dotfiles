if test -e ~/.local/share/fnm/fnm
    fish_add_path -a ~/.local/share/fnm
    fnm env --use-on-cd --shell fish | source
end

# fnm
set FNM_PATH "/home/alexrudy/.local/share/fnm"
if [ -d "$FNM_PATH" ]
  set PATH "$FNM_PATH" $PATH
  fnm env | source
end

# fnm
set FNM_PATH "/home/alexrudy/.local/share/fnm"
if [ -d "$FNM_PATH" ]
  set PATH "$FNM_PATH" $PATH
  fnm env | source
end
