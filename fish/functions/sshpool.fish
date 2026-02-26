function sshpool -a host session -d "SSH and attach to a shpool session"
    ssh -t "-oRemoteCommand=shpool attach -f $session" "$host"
end
