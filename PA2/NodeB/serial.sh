#!/bin/bash
if [ $# -eq 1 ];
then
	gnome-terminal --title="SF@9001 for Node B" -x bash -c "cd sf_programs;./sf 9001 $1 115200;read n1";
	gnome-terminal --title="Node B" -x bash -c "cd sf_programs;./receiver.py 127.0.0.1 9001;read n1";
else
	echo "Usage: <device port e.g. /dev/ttyUSB0>";
	exit 65;
fi
