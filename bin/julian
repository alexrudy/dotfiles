#!/bin/sh
# © Alex Rudy - Pomona College
# June 11 2008

USAGE='
	julian.sh - Simple Julian Date Conversion Tool
	(c) Alexander Rudy - Pomona College
SYNTAX: julian.sh datefile
Where datefile is a text file containing the date to be converted in FITS header format.
SYNTAX: julian.sh date
Where date is the georgian date to be converted, in FITS header format.

The FITS header format is equivalent to %Y-%m-%dT%H:%M:%S in standard UNIX date.
'


if [ $# -eq 0 ]
then
	echo "$USAGE"
	exit
fi

directory=`pwd`

datefile=$1

if [ -e $datefile ]
then
gdate=`cat $datefile`
else
gdate=$1
fi

year=`echo $gdate | cut -d"-" -f1`

month=`echo $gdate | cut -d"-" -f2`

temp=`echo $gdate | cut -d"-" -f3`

day=`echo $temp | cut -d"T" -f1 -`

temp2=`echo $temp | cut -d"T" -f2 -`

hour=`echo $temp2 | cut -d":" -f1 -`

minute=`echo $temp2 | cut -d":" -f2 -`

second=`echo $temp2 | cut -d":" -f3 -`

scale="10"

tmonth=`echo "$month" | sed 's/0*//'`

iscale="0"

a=`echo "scale=$iscale; ((14-$month)/12)" | bc`
y=`echo "scale=$iscale; $year + 4800 - $a" | bc`
m=`echo "scale=$iscale; $month + 12*$a - 3" | bc`
jday=`echo "scale=$iscale; $day + ((153 * $m + 2) / 5 )  + 365 * $y + ($y / 4) - ($y / 100) + ($y / 400) - 32045" | bc`

jhour=`echo "scale=$scale; ($hour - 12) / 24" | bc`

jminute=`echo "scale=$scale; $minute / 1440" | bc`

jsecond=`echo "scale=$scale; $second / 86400" | bc`

juliand=`echo "scale=$scale; $jday + $jhour + $jminute + $jsecond" | bc`

echo "$juliand"
