#!/bin/bash
SOURCE_XML="testmulti.xml"
DBTYPE="mysql"
CLUSTER_NAME="openstack"
TYPE="modify"

show_usage()
{

	echo
    echo "****************************************************************************************"
    echo "Note: This scripts is modify nodelist to install openstack"
	echo "Usage: ./modifylist.sh -s <CONTROLLER_IP> -c <COMPUTE_IP> -n <CLUSTER_NAME> "
#	echo "       ./modifylist.sh add <CLUSTER_NAME> <NEW_COMPUTE_IP>"
	echo "       ./modifylist.sh update <CLUSTER_NAME> <ITEM_TO_CHANGED> <VALUE>"
    echo "Default values:" 
    echo " 1. SOURCE_XML is 'nodelist.xml'  (configurable)"
    echo " 2. DBTYPE is 'mysql' (configurable)"
    echo " 3. NETWORKTYPE is 'nova-network' (configurable)"
    echo " 4. CLUSTER_NAME is 'openstack' (configurable)"
    echo "****************************************************************************************"
	echo
}

modify()
{
	ENV_NAME=$CLUSTER_NAME
	DEST_XML=$ENV_NAME".xml"
	cp $SOURCE_XML $DEST_XML
	sed -i 's/CONTROLLER_NODE/'$CONTROLLER_IP'/g' $DEST_XML
	sed -i 's/COMPUTE_NODE/'$COMPUTE_IP'/g' $DEST_XML
	sed -i 's/ENV_NAME/'$CLUSTER_NAME'/g' $DEST_XML
	sed -i 's/CLUSTER_NAME/'$CLUSTER_NAME'/g' $DEST_XML
}

add()
{
	ENV_NAME=$CLUSTER_NAME
	DEST_XML=$ENV_NAME".xml"
	if [ ! -f $DEST_XML ]; then
		echo $DEST_XML" does not exist! Please run ' ./modifylist.sh -s <CONTROLLER_IP> -c <COMPUTE_IP> -n <CLUSTER_NAME>' to create first"
		exit 1
	fi
	cp $DEST_XML tmp
	
	rm -f tmp
	
}

update()
{
	ENV_NAME=$CLUSTER_NAME
	DEST_XML=$ENV_NAME".xml"
	if [ ! -f $DEST_XML ]; then
		echo $DEST_XML" does not exist! Please run ' ./modifylist.sh -s <CONTROLLER_IP> -c <COMPUTE_IP> -n <CLUSTER_NAME>' to create first"
		exit 1
	fi
	cp $DEST_XML tmp
	awk '{if(/'$ITEM'/){sub(/>[^<]*</,">'$VALUE'<")}print}' tmp > $DEST_XML
	rm -f tmp
}

if [ "$1" == "-s" ]; then CONTROLLER_IP=$2; elif [ "$1" == "-c" ]; then COMPUTE_IP=$2; elif [ "$1" == "-n" ]; then CLUSTER_NAME=$2; fi
if [ "$3" == "-s" ]; then CONTROLLER_IP=$4; elif [ "$3" == "-c" ]; then COMPUTE_IP=$4; elif [ "$3" == "-n" ]; then CLUSTER_NAME=$4; fi
if [ "$5" == "-s" ]; then CONTROLLER_IP=$6; elif [ "$5" == "-c" ]; then COMPUTE_IP=$6; elif [ "$5" == "-n" ]; then CLUSTER_NAME=$6; fi

if [ "$CONTROLLER_IP" == "" -o "$COMPUTE_IP" == "" -o "$CLUSTER_NAME" == "" ]; then
	if [ "$1" == "add" ]; then echo "add compute node"; TYPE="add"; CLUSTER_NAME=$2; NEW_COMPUTE_IP=$3; 
	elif [ "$1" == "update" ]; then echo "update"; TYPE="update"; CLUSTER_NAME=$2; ITEM=$3; VALUE=$4; 
	else
		show_usage; exit 1; 
	fi
fi

cd /root/openstackchef/openstack-installation/install-scripts/

if [ "$TYPE" == "modify" ]; then
	modify
elif [ "$TYPE" == "add" ]; then
	add
elif [ "$TYPE" == "update" ]; then
	update
else
	show_usage
	exit 1
fi
