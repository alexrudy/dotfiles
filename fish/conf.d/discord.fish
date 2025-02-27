set omf_foreign_env ~/Development/oh-my-fish/plugin-foreign-env/functions
set nix_profile ~/.nix-profile/etc/profile.d/nix.sh

if test -d $omf_foreign_env

    set fish_function_path $fish_function_path $omf_foreign_env

    if test -f $nix_profile
        fenv source $nix_profile
    end
end
