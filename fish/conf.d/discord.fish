set omf_foreign_env ~/Development/oh-my-fish/plugin-foreign-env/functions
set nix_profile ~/.nix-profile/etc/profile.d/nix.sh

if test -d $omf_foreign_env

    set fish_function_path $fish_function_path $omf_foreign_env

    if test -f $nix_profile
        fenv source $nix_profile
    end
end

if set -q "$CODER"
    set -gx STARSHIP_CONFIG "$HOME/.config/starship.discord.toml"
    if command -v code
        set -gx EDITOR "code -w"
    end
else
    function ssc -a workspace;
       ssh "coder.$workspace"
    end
end
