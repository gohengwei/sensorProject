#!bin/bash

if [ $# -eq 4 ];
then
	cd NodeA;
	echo "[script]\033[40;37m Node id $3 is used for Node A \033[0m"
	sh make.sh $1 $3; 
	cd ..;
	cd NodeB;
	echo "[script]\033[40;37m Node id $4 is used for Node B\033[0m"
	sh make.sh $2 $4;
	echo "[script]\033[40;37m Setting up Node A Serial Forwarder and Opening TCP port to receive on 9000 \033[0m"
	cd ..;
	cd NodeA;
	sh serial.sh $1;
	echo "[script]\033[40;37m Setting up Node B Serial Forwarder and Opening TCP port to receive on 9001 \033[0m"
	cd ..;
	cd NodeB;
	sh serial.sh $2;
else
	echo "Usage: sh PA2make.sh <NodeA port e.g. /dev/ttyUSB0> <NodeB port> <NodeA node id e.g. 2> <NodeB node id>";
	exit 65;
fi
