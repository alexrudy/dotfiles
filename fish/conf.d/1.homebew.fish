if test -e /opt/homebrew/bin/brew
    fish_add_path -p /opt/homebrew/bin
    fish_add_path -a /opt/homebrew/sbin
    set -gx HOMEBREW_PREFIX /opt/homebrew
end
