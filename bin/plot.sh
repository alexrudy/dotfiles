#!/bin/bash

if [ -f start.sm ]
then
	echo "start.sm exists!"
else
	echo "Creating start.sm"
	echo '	input "/Users/alexanderrudy/Development/MARLA/trunk/Plotting/plot.sm"' > start.sm
fi
	
sm input start.sm
