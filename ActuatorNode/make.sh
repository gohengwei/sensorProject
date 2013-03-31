#!/bin/bash
if [ $# -eq 2 ];
then
	sudo chmod 666 $1;
	make telosb;
	echo "node $2 is used.";
	make telosb reinstall.$2 bsl,$1;
else
	echo "Usage: ./make <device port e.g. /dev/ttyUSB0> <node id e.g. 1>";
	exit 65;
fi
