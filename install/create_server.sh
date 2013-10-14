#!/bin/sh
#set -x 
function place_order() {
    hostname1=`echo $1 | cut -d'.' -f 1`
    domain1=`echo $1 | cut -d'.' -f 2-`
    echo "...... Baremetal provision request ......"
    sleep 5
    echo "...... provision $hostname1 request ......"
    sl bmc create --hostname=$hostname1 --domain=$domain1 --cpu=2 --memory=2 \
        --os=CENTOS_6_64_MINIMAL  --disk=500 --hourly -y &
    if [ $? -ne 0 ]; then
        exit 2
    fi
    hostname2=`echo $2 | cut -d'.' -f 1`
    domain2=`echo $2 | cut -d'.' -f 2-`
    echo "...... provision $hostname2 request ......"
    sl bmc create --hostname=$hostname2 --domain=$domain2 --cpu=2 --memory=2 \
        --os=CENTOS_6_64_MINIMAL  --disk=500 --hourly -y &
    if [ $? -ne 0 ]; then
        exit 2
    fi
}    

function wait_for_ready() {
    while :; do
        sleep 1
        id1=`sl server list | grep $1 | cut -d' ' -f 1`
        id2=`sl server list | grep $2 | cut -d' ' -f 1`
        if [ -n "$id1" ] && [ -n "$id2" ]; then
           break;
        fi
    done
    echo "...... Request baremetal status ......"    
    while :; do
        sleep 1
        detail1=`sl server detail --password $id1`
        status1=`echo "$detail1" | grep status | awk '{print \$2}'`
        detail2=`sl server detail --password $id2`
        status2=`echo "$detail2" | grep status | awk '{print \$2}'`
        if [ "$status1" = "ACTIVE" ] && [ "$status2" = "ACTIVE" ]; then
            break;
        fi
    done

    ip1=`echo "$detail1" | grep private_ip | awk '{print \$2}'`
    public_ip1=`echo "$detail1" | grep public_ip | awk '{print \$2}'`
    password1=`echo "$detail1" | grep users | grep root | awk '{print $3}'`
    ip2=`echo "$detail2" | grep private_ip | awk '{print \$2}'`
    public_ip2=`echo "$detail2" | grep public_ip | awk '{print \$2}'`
    password2=`echo "$detail2" | grep users | grep root | awk '{print $3}'`
    echo $ip1 $password1 $public_ip1 > $3
    echo $ip2 $password2 $public_ip2 >> $3
}

# Main program 
if [ $# -lt 1 ]; then
    echo "Usage: $0 <hostname>"
    exit 1
fi

if [ "$4" == "-y" ]; then
    place_order $1 $2
    wait_for_ready $1 $2 $3 
elif [ "$4" == "-n" ]; then
    wait_for_ready $1 $2 $3
fi
