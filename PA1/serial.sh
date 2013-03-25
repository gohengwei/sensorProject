#!/bin/bash
if [ $# -eq 4 ];
then
	gnome-terminal --title="Serial Forwarder" -x bash -c "cd sf_programs;./sf 9001 $1 115200;read n1";
	gnome-terminal --title="Receiver" -x bash -c "cd sf_programs;./receiver.py 127.0.0.1 9001;read n1";
	sleep 1;
	gnome-terminal --title="Sender" -x bash -c "cd sf_programs;./send.py 127.0.0.1 9001 $2 $3 $4 0 0 0 0 0 0 0;read n1";
else
	echo "Usage: <device port e.g. /dev/ttyUSB0> <LED0 duration> <LED1 duration> <LED2 duration>";
	exit 65;
fi
