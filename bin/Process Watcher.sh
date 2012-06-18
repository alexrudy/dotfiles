#!/bin/bash

ps -A -o command > start

while true
do
ps -A -o command > running
results=`diff start running`
datenow=`date %Y%m%d %H%M%S`
echo "$results $date" > processwatcher.log
echo "$results $date"
done