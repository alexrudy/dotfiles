echo "CS Sync for CS 062 Eclipse Workspace"
echo "Uplink Sync"
rsync -a --progress ~/Documents/Pomona/2009SPRING/CSCI062/Workspace/ arudy@vpn.cs.pomona.edu:~/cs062/workspace/
echo "Downlink Sync"
rsync -a --progress arudy@vpn.cs.pomona.edu:~/cs062/workspace/ ~/Documents/Pomona/2009SPRING/CSCI062/Workspace/
echo "Done..."