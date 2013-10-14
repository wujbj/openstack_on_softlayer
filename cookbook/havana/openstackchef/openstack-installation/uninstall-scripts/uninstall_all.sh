#!/bin/bash

nodes=$(knife node list)

knife node list | xargs -i knife client delete -y {}
knife node list | xargs -i knife node delete -y {}

dir=$(cd $(dirname $0) && pwd)

for node in $nodes
do
    ssh $node < $dir/uninstall_openstack.sh &>/dev/null &
done
