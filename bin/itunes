#!/bin/bash
# © Alexander Rudy

log=$1

entries=3253

echo $entries
endd=`echo "scale=1; $entries+1" | bc`

for ((i=1; i<$endd; i++))
do

head -n$i $log > temp1.t
tail -n1 temp1.t > file.t

#sed 's/\ /\\\ /g' file.t>file2.t
directory=`pwd`
cparg1="$directory/`cat file.t`"
cparg2="/Users/alexanderrudy/fromben/"

#echo "$cparg1" $cparg2
cp "$cparg1" $cparg2

echo $cparg1

done
