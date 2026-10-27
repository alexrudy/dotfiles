function ssh-fw-auth -a host port -d "Connect and forward a single port for oAuth"
    ssh -N -L "$port:localhost:$port" "$host"
end
