#!/bin/bash
current=`pwd`
nodepath="/root/openstackchef/openstack-installation/install-scripts"
env_name="openstack"
show_usage()
{
	echo
	echo "****************************************************************************************"
	echo "Usage: ./install.sh -s <CONTROLLER_NAME> -c <COMPUTE_NAME>"	
	echo "****************************************************************************************"
	echo
}

if [ "$1" == "-s" ]; then controller_name=$2; elif [ "$1" == "-c" ]; then compute_name=$2;  fi
if [ "$3" == "-s" ]; then controller_name=$4; elif [ "$3" == "-c" ]; then compute_name=$4;  fi
if [ "$5" == "-s" ]; then controller_name=$6; elif [ "$5" == "-c" ]; then compute_name=$6;  fi

if [ "$controller_name" == "" -o "$compute_name" == "" ]; then
	show_usage
	exit 1
fi

echo "Step 1: Provision a controller server use SoftLayer API "
echo 
cd $current
result=`python getserver.py $controller_name $compute_name`
sresult=`echo $result|awk -F '/' '{print $1}'`
cresult=`echo $result|awk -F '/' '{print $2}'`
#sresult=`./create_server $controller_name`
#sresult="10.66.222.216 root 119.81.66.35"
sip=`echo $sresult | awk -F ' ' '{print $1}' `
spassword=`echo $sresult | awk -F ' ' '{print $2}' `
spip=`echo $sresult | awk -F ' ' '{print $3}' `
echo $sip $spassword $spip
#sleep 10

#echo "Step 2: Provision a compute server use SoftLayer API "
#echo
#cresult=`./create_server $compute_name`
#cresult="10.66.222.226 ZXF6cqaP 119.81.66.40"
cip=`echo $cresult | awk -F ' ' '{print $1}' `
cpassword=`echo $cresult | awk -F ' ' '{print $2}' `
cpip=`echo $cresult | awk -F ' ' '{print $3}' `
echo $cip $cpassword $cpip
#sleep 10

echo "Step 3: Deploy Openstack"
echo 
./setssh.sh $sip root $spassword
./setssh.sh $cip root $cpassword
./modifylist.sh -s $sip -c $cip -n $env_name
echo "$sip $controller_name" >> /etc/hosts
echo "$cip $compute_name" >> /etc/hosts
scp /etc/hosts $sip:/etc/hosts
scp /etc/hosts $cip:/etc/hosts

cd /root/openstackchef/openstack-installation/install-scripts/
#knife cookbook list | awk '{print $1}' | xargs -i knife cookbook delete -y {}
./install_openstack.py -f $env_name.xml -n $env_name -E -R -U -C
./install_openstack.py -f $env_name.xml -n $env_name -E -D
echo "=====================install===================================="
sleep 5
./install_openstack.py -f $env_name.xml -n $env_name -E --all 
sleep 5

echo "Step 4: chech service status"
echo
cp $nodepath/$env_name.xml $current/service/
cd $current/service/
python CheckOpenstack.py $nodepath/$env_name.xml 
