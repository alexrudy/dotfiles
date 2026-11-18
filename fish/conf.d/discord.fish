set omf_foreign_env ~/Development/oh-my-fish/plugin-foreign-env/functions
set nix_profile ~/.nix-profile/etc/profile.d/nix.sh

if test -d $omf_foreign_env

    set fish_function_path $fish_function_path $omf_foreign_env

    if test -f $nix_profile
        fenv source $nix_profile
    end
end

if set -q CODER
    set -gx STARSHIP_CONFIG "$HOME/.config/starship.discord.toml"
    if command -q code
        set -gx EDITOR "code -w"
    end
    # The coder agent's SHELL comes from systemd, which reads /etc/passwd when
    # the agent starts, before ~/personalize runs chsh. So every session
    # inherits the image's default shell unless we correct it here.
    set -gx SHELL "/usr/bin/fish"
else
    function ssc -a workspace;
       ssh "coder.$workspace"
    end
end

fish_add_path -m -a $HOME/.nix-profile/bin
fish_add_path -m -a /nix/var/nix/profiles/default/bin

if test -d ~/Development/discord/discord
    fish_add_path -p ~/Development/discord/discord/.local/bin
end

abbr --add ghostty-info --set-cursor infocmp -x xterm-ghostty \| ssh % -- tic -x -
