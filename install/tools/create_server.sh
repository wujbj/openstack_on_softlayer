#!/bin/sh
set -x
function place_order() {
    hostname=`echo $1 | cut -d'.' -f 1`
    domain=`echo $1 | cut -d'.' -f 2-`
    sl bmc create --hostname=$hostname --domain=$domain --cpu=2 --memory=2 \
        --os=CENTOS_6_64_MINIMAL  --disk=500 --hourly -y
    if [ $? -ne 0 ]; then
        exit 2
    fi
}    

function wait_for_ready() {
    while :; do
        sleep 1
        id=`sl server list | grep $1 | cut -d' ' -f 1`
        if [ -n "$id" ]; then
           break;
        fi
    done
    
    while :; do
        sleep 1
        result=`sl server detail --password $id`
        status=`echo "$result" | grep status | awk '{print \$2}'`
        if [ "$status" = "ACTIVE" ]; then
            break;
        fi
    done

    ip=`echo "$result" | grep private_ip | awk '{print \$2}'`
    public_ip=`echo "$result" | grep public_ip | awk '{print \$2}'`
    password=`echo "$result" | grep users | grep root | awk '{print $3}'`
#    echo "ip=$ip"
#    echo "password=$password"
    echo $ip $password $public_ip
}

# Main program 
if [ $# -lt 1 ]; then
    echo "Usage: $0 <hostname>"
    exit 1
fi

#place_order $1
wait_for_ready $1
