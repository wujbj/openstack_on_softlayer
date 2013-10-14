#!/bin/bash
#set -x
current=`pwd`
nodepath="/root/openstackchef/openstack-installation/install-scripts"
show_usage()
{
	echo
	echo "****************************************************************************************"
	echo "Usage: ./install.sh -s <CONTROLLER_NAME> -c <COMPUTE_NAME> -e <CLUSTER_NAME> -y/-n"	
    echo "CONTROLLER_NAME is the hostname of controller"
    echo "COMPUTE_NAME is the hostname of compute"
    echo "CLUSTER_NAME is the name of the openstack cluster"
    echo "If controller and compute server has created before, pleasy use -n option"
    echo "If controller and compute server has not created before, pleasy use -y option"
	echo "****************************************************************************************"
	echo
}

if [ "$1" == "-s" ]; then controller_name=$2; elif [ "$1" == "-c" ]; then compute_name=$2;  elif [ "$1" == "-e" ]; then env_name=$2; fi
if [ "$3" == "-s" ]; then controller_name=$4; elif [ "$3" == "-c" ]; then compute_name=$4;  elif [ "$3" == "-e" ]; then env_name=$4; fi
if [ "$5" == "-s" ]; then controller_name=$6; elif [ "$5" == "-c" ]; then compute_name=$6;  elif [ "$5" == "-e" ]; then env_name=$6; fi
iscreate=$7

if [ "$controller_name" == "" -o "$compute_name" == "" -o "$env_name" == "" ]; then
	show_usage
	exit 1
fi

echo -e "\e[37;42;1mStep 1: Provision controller and compute server using SoftLayer API \e[0m"
echo 
cd $current
./create_server.sh $controller_name $compute_name $env_name $iscreate
sresult=`sed -n '1p' $env_name`
cresult=`sed -n '2p' $env_name`
sip=`echo $sresult | awk -F ' ' '{print $1}' `
spassword=`echo $sresult | awk -F ' ' '{print $2}' `
spip=`echo $sresult | awk -F ' ' '{print $3}' `
#echo $sip $spassword $spip

cip=`echo $cresult | awk -F ' ' '{print $1}' `
cpassword=`echo $cresult | awk -F ' ' '{print $2}' `
cpip=`echo $cresult | awk -F ' ' '{print $3}' `
#echo $cip $cpassword $cpip

echo
echo -e "\e[37;42;1mStep 2: Pre-deploy preparation \e[0m"
echo
./setssh.sh $sip root $spassword
./setssh.sh $cip root $cpassword
./modifylist.sh -s $sip -c $cip -n $env_name
controller_name_former=`echo $controller_name | awk -F '.' '{print $1}'`
compute_name_former=`echo $compute_name | awk -F '.' '{print $1}'`
echo "$sip $controller_name $controller_name_former" >> /etc/hosts
echo "$cip $compute_name $compute_name_former" >> /etc/hosts
scp /etc/hosts $sip:/etc/hosts 
scp /etc/hosts $cip:/etc/hosts 
echo
echo -e "\e[37;42;1mStep 3: Deploy Openstack \e[0m"
echo 
sleep 5
cd /root/openstackchef/openstack-installation/install-scripts/
#knife cookbook list | awk '{print $1}' | xargs -i knife cookbook delete -y {}
knife node list | xargs -i knife client delete -y {}
knife node list | xargs -i knife node delete -y {}
./install_openstack.py -f $env_name.xml -n $env_name -E -R -U -C
./install_openstack.py -f $env_name.xml -n $env_name -E -D
echo "=====================install===================================="
./install_openstack.py -f $env_name.xml -n $env_name -E --all 
echo
echo -e "\e[37;42;1mStep 4: Check service status \e[0m"
echo
sleep 5
cp $nodepath/$env_name.xml $current/service/
cd $current/service/
python CheckOpenstack.py $nodepath/$env_name.xml 
