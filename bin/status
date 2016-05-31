#!/usr/bin/env bash
# Yay for Comments!
echo "System Status Report"
date
echo -n "System uptime and load:" ;uptime
echo -n "Operating System: " ; sysctl -n kern.ostype
echo -n "OS Version: " ; sysctl -n kern.osrelease
echo -n "OS Revision Number: " ; sysctl -n kern.osrevision
echo -n "Hostname: " ; sysctl -n kern.hostname

bytes=`sysctl -n hw.physmem`
megabytes=`expr $bytes / 1024 / 1024`

echo "Physical Memory installed (Mb): $megabytes"
