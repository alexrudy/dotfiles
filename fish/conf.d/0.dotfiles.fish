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

fish_source_dotfiles -name 'env.fish'
fish_source_dotfiles -name '*.fish' -not -name 'env.fish'
fish_add_paths -name bin
