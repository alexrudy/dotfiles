set gopath ~/go
if test -d $gopath
    set -x GOPATH $gopath
    fish_add_path -a $gopath/bin
end
