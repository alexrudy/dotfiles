# Alex Rudy
# 2009-03-25
#

echo "idisksync.sh Backup Script"
echo "Syncing iDisk: 2009SPRING"
rsync -a --max-size=5000 --progress ~/Documents/Pomona/2009SPRING/ /Volumes/alex.rudy/Documents/2009SPRING/
rsync -a --max-size=5000 --progress /Volumes/alex.rudy/Documents/2009SPRING/ ~/Documents/Pomona/2009SPRING/
echo "Syncing iDisk: 2009SUMMER"
rsync -a --max-size=5000 --progress ~/Documents/Pomona/2009SUMMER/ /Volumes/alex.rudy/Documents/2009SUMMER/
rsync -a --max-size=5000 --progress /Volumes/alex.rudy/Documents/2009SUMMER/ ~/Documents/Pomona/2009SUMMER/
echo `date` 'sync complete' '2009SPRING 2009SUMMER' >> /Volumes/alex.rudy/Documents/idisksync.log
echo "End Folder Sync, Starting MobileMe Sync"
/System/Library/PrivateFrameworks/DotMacSyncManager.framework/Versions/A/Resources/dotmacsyncclient sync
echo "End MobileMe Sync"