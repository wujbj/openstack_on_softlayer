#!/bin/bash
#Create a Chef Server VM
#Author: Tao Tao

#######Variables#########
SCRIPT_NAME=`basename $0`
CURRENT_DIR=$(dirname $0)
LOG_DIR="/tmp/log"

SRC_IMG_PATH="/home/images/raw/chef-server-11"
GUEST_IMG_NAME="chef-server-11.img"
GUEST_SPEC_FILE="instance.xml"
NEW_VM_GW="172.16.0.1"
NEW_VM_NETMASK="255.255.0.0"

NEW_VM_UUID=`uuidgen`
NEW_VM_MAC_ADDRESS=`echo "fa:16:$(dd if=/dev/urandom count=1 2>/dev/null | md5sum | sed 's/^\(..\)\(..\)\(..\)\(..\).*$/\1:\2:\3:\4/')"`

######knife bootstrap run function######
start_foreground_process()
{
	JOB_STRING=$1 
	echo "$JOB_STRING"
	bash -c "$JOB_STRING"
	retval=$?
	new_foreground_pid=$!
	return $retval
}

######OpenStack component status checking function######
status_check()
{
	status=$1

	if [ $status -ne 0 ]
	then
		echo "Instalaltion Failure: STATUS<${status}"
		exit 1
	fi
	
}

######Usage function######
show_usage()
{
	echo
    echo "****************************************************************************************"
    echo "Note: This scripts is used to standup a Chef Server VM based on a RAW Chef Server image."
	echo "Usage: $SCRIPT_NAME -s <SRC_RAW_IMG_PATH> -t <NEW_VM_PATH> -n <NEW_VM_NAME> -p <NEW_VM_IP> -g <NEW_VM_GW> -m <NEW_VM_NETMASK>"
    echo "Default values:" 
    echo " 1. SRC_RAW_IMG_PATH is '/home/images/raw/chef-server-11' (configurable)"
    echo " 2. NET_VM_GW is '172.16.0.1' (configurable)"
    echo " 3. NET_VM_NETMASK is '255.255.0.0' (configurable)"
    echo " 4. GUEST IMAGE NAME is 'chef-server-11.img' (to be configurable)"
    echo " 5. GUEST DOMAIN SPECIFICATION is 'instance.xml' (to be configurable)"
    echo "****************************************************************************************"
	echo
}

if [ "$1" == "-s" ]; then SRC_IMG_PATH=$2; elif [ "$1" == "-t" ]; then NEW_VM_PATH=$2; elif [ "$1" == "-n" ]; then NEW_VM_NAME=$2; elif [ "$1" == "-p" ]; then NEW_VM_IP=$2; elif [ "$1" == "-g" ]; then NEW_VM_GW=$2; elif [ "$1" == "-m" ]; then NEW_VM_NETMASK=$2; fi

if [ "$3" == "-s" ]; then SRC_IMG_PATH=$4; elif [ "$3" == "-t" ]; then NEW_VM_PATH=$4; elif [ "$3" == "-n" ]; then NEW_VM_NAME=$4; elif [ "$3" == "-p" ]; then NEW_VM_IP=$4; elif [ "$3" == "-g" ]; then NEW_VM_GW=$4; elif [ "$3" == "-m" ]; then NEW_VM_NETMASK=$4; fi
if [ "$5" == "-s" ]; then SRC_IMG_PATH=$6; elif [ "$5" == "-t" ]; then NEW_VM_PATH=$6; elif [ "$5" == "-n" ]; then NEW_VM_NAME=$6; elif [ "$5" == "-p" ]; then NEW_VM_IP=$6; elif [ "$5" == "-g" ]; then NEW_VM_GW=$6; elif [ "$5" == "-m" ]; then NEW_VM_NETMASK=$6; fi
if [ "$7" == "-s" ]; then SRC_IMG_PATH=$8; elif [ "$7" == "-t" ]; then NEW_VM_PATH=$8; elif [ "$7" == "-n" ]; then NEW_VM_NAME=$8; elif [ "$7" == "-p" ]; then NEW_VM_IP=$8; elif [ "$7" == "-g" ]; then NEW_VM_GW=$8;  elif [ "$7" == "-m" ]; then NEW_VM_NETMASK=$8; fi
if [ "$9" == "-s" ]; then SRC_IMG_PATH=${10}; elif [ "$9" == "-t" ]; then NEW_VM_PATH=${10}; elif [ "$9" == "-n" ]; then NEW_VM_NAME=${10}; elif [ "$9" == "-p" ]; then NEW_VM_IP=${10}; elif [ "$9" == "-g" ]; then NEW_VM_GW=${10};  elif [ "$9" == "-m" ]; then NEW_VM_NETMASK=${10}; fi
if [ "$11" == "-s" ]; then SRC_IMG_PATH=${12}; elif [ "$11" == "-t" ]; then NEW_VM_PATH=${12}; elif [ "$11" == "-n" ]; then NEW_VM_NAME=${12}; elif [ "$11" == "-p" ]; then NEW_VM_IP=${12}; elif [ "$11" == "-g" ]; then NEW_VM_GW=${12};  elif [ "$11" == "-m" ]; then NEW_VM_NETMASK=${12}; fi

if [ "$SRC_IMG_PATH" == "" -o "$NEW_VM_PATH" == "" -o "$NEW_VM_NAME" == "" -o "$NEW_VM_IP" == "" ]; then 
   show_usage;
   exit 1; 
fi

echo "[Start] Chef server VM standup: SRC_IMG_PATH=${SRC_IMG_PATH}, VM_PATH=${NEW_VM_PATH}, VM_NAME=${NEW_VM_NAME}, VM_IP=${NEW_VM_IP}, VM_GATEWAY=${NEW_VM_GW}, VM_NETMASK=${NEW_VM_NETMASK}"

echo "1) Copy the images from source directory to target directory."

cp -rf ${SRC_IMG_PATH}/* ${NEW_VM_PATH}/.

echo "2) Updating new VM domain specification..."

change_vm_name="sed 's|CHEF_SERVER_VM_NAME|${NEW_VM_NAME}|g' ${NEW_VM_PATH}/${GUEST_SPEC_FILE}"
change_vm_path="sed 's|CHEF_SERVER_VM_PATH|${NEW_VM_PATH}|g' ${NEW_VM_PATH}/${GUEST_SPEC_FILE}"
change_vm_uuid="sed 's|CHEF_SERVER_VM_UUID|${NEW_VM_UUID}|g' ${NEW_VM_PATH}/${GUEST_SPEC_FILE}"
change_vm_mac="sed 's|CHEF_SERVER_VM_MAC_ADDRESS|${NEW_VM_MAC_ADDRESS}|g' ${NEW_VM_PATH}/${GUEST_SPEC_FILE}"

echo $change_vm_name
bash -c "${change_vm_name}" > /tmp/1.txt
mv /tmp/1.txt ${NEW_VM_PATH}/${GUEST_SPEC_FILE}

echo $change_vm_path
bash -c "${change_vm_path}" > /tmp/1.txt
mv /tmp/1.txt ${NEW_VM_PATH}/${GUEST_SPEC_FILE}

echo $change_vm_uuid
bash -c "${change_vm_uuid}" > /tmp/1.txt
mv /tmp/1.txt  ${NEW_VM_PATH}/${GUEST_SPEC_FILE} 

echo $change_vm_mac
bash -c "${change_vm_mac}" > /tmp/1.txt
mv /tmp/1.txt  ${NEW_VM_PATH}/${GUEST_SPEC_FILE}

echo "3) Mount the new VM image."

mkdir /tmp/${NEW_VM_UUID}
mount -o loop ${NEW_VM_PATH}/${GUEST_IMG_NAME} /tmp/${NEW_VM_UUID}

echo "4) Update network ip address in the files on the new VM."
change_ifcfg_config1="sed 's|CHEF_SERVER_VM_IP|${NEW_VM_IP}|g' /tmp/${NEW_VM_UUID}/etc/sysconfig/network-scripts/ifcfg-eth0"
change_ifcfg_config2="sed 's|CHEF_SERVER_VM_GATEWAY|${NEW_VM_GW}|g' /tmp/${NEW_VM_UUID}/etc/sysconfig/network-scripts/ifcfg-eth0"
change_ifcfg_config3="sed 's|CHEF_SERVER_VM_NETMASK|${NEW_VM_NETMASK}|g' /tmp/${NEW_VM_UUID}/etc/sysconfig/network-scripts/ifcfg-eth0"
change_knife_config="sed 's|CHEF_SERVER_VM_IP|${NEW_VM_IP}|g' /tmp/${NEW_VM_UUID}/root/.chef/knife.rb"
change_bootstrap_config="sed 's|CHEF_SERVER_VM_IP|${NEW_VM_IP}|g' /tmp/${NEW_VM_UUID}/root/.chef/bootstrap/rhel.erb"
change_chefserver_config="sed 's|CHEF_SERVER_VM_IP|${NEW_VM_IP}|g' /tmp/${NEW_VM_UUID}/etc/chef-server/chef-server.rb"
change_network_config="sed 's|CHEF_SERVER_VM_NAME|${NEW_VM_NAME}|g' /tmp/${NEW_VM_UUID}/etc/sysconfig/network"

rm -f /tmp/${NEW_VM_UUID}/etc/udev/rules.d/70-*

echo $change_ifcfg_config1
bash -c "${change_ifcfg_config1}" > /tmp/1.txt
mv /tmp/1.txt /tmp/${NEW_VM_UUID}/etc/sysconfig/network-scripts/ifcfg-eth0

echo $change_ifcfg_config2
bash -c "${change_ifcfg_config2}" > /tmp/1.txt
mv /tmp/1.txt /tmp/${NEW_VM_UUID}/etc/sysconfig/network-scripts/ifcfg-eth0

echo $change_ifcfg_config3
bash -c "${change_ifcfg_config3}" > /tmp/1.txt
mv /tmp/1.txt /tmp/${NEW_VM_UUID}/etc/sysconfig/network-scripts/ifcfg-eth0

echo $change_knife_config
bash -c "${change_knife_config}" > /tmp/1.txt
mv /tmp/1.txt /tmp/${NEW_VM_UUID}/root/.chef/knife.rb

echo $change_bootstrap_config
bash -c "${change_bootstrap_config}" > /tmp/1.txt
mv /tmp/1.txt /tmp/${NEW_VM_UUID}/root/.chef/bootstrap/rhel.erb
 
echo $change_chefserver_config
bash -c "${change_chefserver_config}" > /tmp/1.txt
mv /tmp/1.txt /tmp/${NEW_VM_UUID}/etc/chef-server/chef-server.rb

echo $change_network_config
bash -c "${change_network_config}" > /tmp/1.txt
mv /tmp/1.txt /tmp/${NEW_VM_UUID}/etc/sysconfig/network 

echo "5) Unmount the new VM image."

umount /tmp/${NEW_VM_UUID}
rm -rf /tmp/${NEW_VM_UUID}

echo "6) Start up the new VM."

virsh create ${NEW_VM_PATH}/${GUEST_SPEC_FILE}
#ssh ${NEW_VM_IP} 'chef-server-ctl reconfigure'
#ssh $NEW_VM_IP} 'chef-server-ctl status'

echo "[End] Chef server VM standup."

exit 0
