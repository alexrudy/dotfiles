# Source all fish files in the dotfiles directory
#
# Add relevant bin/ directories to the fish path

set -gx DOTFILES "$HOME/.dotfiles"

function fish_source_dotfiles
    set -l fish_env_files
    find "$DOTFILES" -maxdepth 3 -not -path "$DOTFILES"'/fish/*' -type f $argv -print | while read -d '\n' file
        source $file
    end
end

function fish_add_paths
    set -l fish_bin_paths
    find "$DOTFILES" -maxdepth 2 -type d $argv -print | while read -d '\n' path
        fish_add_path -g $path
    end
end

# Read a declarative dotfiles env file. Format mirrors the POSIX loader in
# core/functions.sh — see that file for the directive list.
function _dotfiles_load_env --argument-names file
    test -r $file; or return 0
    while read -l line
        switch $line
            case '' '#*'
                continue
        end
        set -l parts (string split -m 1 ' ' -- $line)
        set -l directive $parts[1]
        set -l arg ''
        if test (count $parts) -gt 1
            set arg $parts[2]
        end
        set arg (string replace -a -- '$HOME' $HOME $arg)
        set arg (string replace -a -- '$DOTFILES' $DOTFILES $arg)
        switch $directive
            case path
                test -d $arg; and fish_add_path -a $arg
            case path-prepend
                test -d $arg; and fish_add_path -p -m $arg
            case env
                set -l kv (string split -m 1 '=' -- $arg)
                if test (count $kv) -eq 2
                    set -gx $kv[1] $kv[2]
                end
            case '*'
                echo "dotfiles: unknown directive '$directive' in $file" >&2
        end
    end < $file
end

# Shell-agnostic .env files first so anything sourced later can rely on the
# variables and PATH entries they declare.
find "$DOTFILES" -mindepth 2 -maxdepth 2 -name '*.env' -print | while read -d '\n' envfile
    _dotfiles_load_env $envfile
end

fish_source_dotfiles -name 'env.fish'
fish_source_dotfiles -name '*.fish' -not -name 'env.fish'
fish_add_paths -name bin
