#!/bin/bash

#Ben Holt's fun jot script!
#http://theholtsite.com
#ben @ theholtsite.com

#Help from http://unixjunkie.blogspot.com/2007/10/generating-random-words.html

line=150
n=`cat /usr/share/dict/words | wc -l`

clear; echo; echo "I'm a code monkey! I can type all day! To stop me, press Control-C."; echo
echo "What should I type?"; echo

echo "1) Shakespeare/Lorem Ipsum"
echo "2) Spew Code!"
echo "3) Random English Words"
echo
echo ""

read arg

clear

case $arg in
    1)
    #Word spam
    while [ 1 ]; do
        nice jot -r -n -c $line a z | rs -g | sed -e "s/..\{`jot -r 1 3 6`\}/ &/g" | sed -e "s/..\{`jot -r 1 3 6`\}/ &/g" | sed -e "s/[ ]\{2,\}/ /g" | tr -d "[:cntrl:]"
        sleep .2
    done
;;
    2)    
    #Code spam
    while [ 1 ]; do
        nice jot -r -s "" -c `jot -r 1 1 $line` | sed -e "s/.\{`jot -r 1 4 6`\}/ &/g" | sed -e "s/.\{`jot -r 1 4 6`\}/ &/g" | tr -d "[:cntrl:]" | sed -e "s/.\{`jot -r 1 1 $line`\}//g" | tr "[:upper:]" "[:lower:]"
        sleep .2
    done
;;
    3)
    while [ 1 ]; do
    #Random English
        #perl -nle '$word = $_ if rand($.) < 1; END { print $word }' /usr/share/dict/words | tr "[:cntrl:]" " "
        cat /usr/share/dict/words | head -`jot -r 1 1 $n` | tail -1 | tr '\012' " "
        sleep .1
    done
;;
*)
    echo "Not a valid command."
    exit
esac
    
done
