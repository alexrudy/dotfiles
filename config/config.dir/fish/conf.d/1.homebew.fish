if not command -v brew > /dev/null
    if test -d /opt/homebrew/bin/brew
        fish_add_path -p /opt/homebrew/bin
        fish_add_path -a /opt/homebrew/sbin
    end
end
