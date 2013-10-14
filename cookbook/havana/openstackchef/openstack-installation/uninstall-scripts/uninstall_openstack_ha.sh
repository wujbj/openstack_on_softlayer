#!/bin/bash

services=(mysqld openstack-keystone qpidd keepalived haproxy \
        openstack-glance-api openstack-glance-registry openstack-nova-api \
        openstack-nova-metadata-api openstack-nova-conductor dnsmasq \
        openstack-nova-scheduler openstack-cinder-api openstack-cinder-volume \
        openstack-cinder-scheduler openvswitch openstack-nova-compute \
        neutron-server neutron-dhcp-agent neutron-l3-agent openvswitch \
        neutron-openvswitch-agent neutron-metadata-agent neutron-ovs-cleanup \
        neutron-server neutron-dhcp-agent neutron-l3-agent  \
        neutron-openvswitch-agent neutron-metadata-agent neutron-ovs-cleanup \
	)

packages=(mysql mysql-server chef haproxy keepalived sshpass \
        openstack-keystone python-keystone python-keystoneclient \
        python-neutronclient python-neutron openstack-neutron-openvswitch \
        openstack-neutron openstack-neutron-metaplugin \
	openvswitch kmod-openvswitch \
        python-neutronclient python-neutron openstack-neutron-openvswitch \
        openstack-neutron openvswitch openstack-neutron-metaplugin \
        openstack-nova-common python-nova python-novaclient \
        openstack-nova openstack-nova-api \
        openstack-nova-cert MySQL-python \
        openstack-nova-cells python-cinderclient \
        openstack-nova-console \
        openstack-nova-compute openstack-nova-network \
        openstack-nova-conductor openstack-nova-scheduler \ 
        openstack-glance python-glance python-glanceclient \
        openstack-nova-scheduler \
        openstack-cinder python-cinder python-cinder-client \
        python-qpid-qmf qpid-cpp-server qpid-qmf qpid-tools \
        python-qpid qpid-cpp-client \
        python-django-openstack-auth python-django-compressor \
        python-django-appconf python-django-horizon \
        openstack-dashboard python-oslo-config \
	python-websockify )

scepackages=(python-cinder-sce openstack-cinder-sce \
        openstack-nova-common-sce python-nova-sce \
        openstack-nova-compte-sce \
        openstack-neutron-openvswitch-sce \
        openstack-neutron-openvswitch-sce \
        python-glance-sce )

users=(keystone glance nova cinder neutron neutron)

files=(/var/lib/mysql /var/log/mysql /etc/my.cnf /etc/mysql* \
        /root/.my.cnf /root/mysql-init /root/.mysql_history \
        /etc/keepalived /etc/haproxy /etc/chef /var/chef \
        /etc/qpid /etc/qpidd.* /var/lib/qpidd /etc/yum.repos.d/* \
        /var/log/keystone /var/lib/keystone /etc/keystone \
        /etc/glance /var/lib/glance /var/log/glance \
        /etc/nova /var/lib/nova /var/log/nova \
        /etc/cinder /var/lib/cinder /var/log/cinder \
        /etc/neutron /var/lib/neutron /var/log/neutron \
        /etc/neutron /var/lib/neutron /var/log/neutron \
        /etc/iptables.d /usr/sbin/rebuild-iptables /etc/openstack-dashboard \
        /tmp/images \
	/var/cache/neutron /var/cache/neutron /var/cache/glance /var/cache/cinder /var/cache/nova)

function stop_service(){
    service="$1"
    if [ -f "/etc/init.d/$service" ]; then
        service $service stop
        sleep .1
    fi
}

function remove_package(){
    pkg="$1"
    rpm -q $pkg && yum -y remove $pkg && sleep .1
    yum --setopt=tsflags=noscripts remove $pkg -y > /dev/null 2>&1
}

function remove_user(){
    user="$1"
    if id $user; then
        userdel -r $user
    fi
}

function remove_file(){
    file="$1"
    str=$(dirname $file)
    if [ "$str" = "/" ]; then
        echo "$file dirname is /"
    else
        rm -rf $file
        sleep 0.1
    fi
}

function remove_stingray(){
    stingray='/usr/local/zeus'
    if [ -e $stingray ]; then
        stop_service zeus
        sleep 2
        stop_service zeus
        sleep 1
        ps aux | awk '/zeus/ {print $2}' | xargs kill -9
        remove_file $stingray
        remove_file /etc/rc3.d/S50zeus
        remove_file /etc/init.d/zeus
    fi
}

function remove_db2(){
    if [ -e /opt/ibm ]; then
        if [ -e /root/chef_db2/db2_uninstall.sh ]; then
            bash /root/chef_db2/db2_uninstall.sh
            sleep 1
        fi
        remove_file /etc/ld.so.conf.d/db2_odbc.conf
        remove_file /opt/ibm
        ldconfig
    fi
}

function delete_ovs_bridge(){
    if lsmod | grep -q -w openvswitch; then
        rmmod openvswitch
        modprobe bridge
    fi
    ip link del int-br-vmnet
    # service openvswitch start
    # brs=(br-vmnet br-int br-tun)
    # for br in ${brs[@]}
    # do
    #     if ovs-vsctl br-exists $br; then
    #         ovs-vsctl del-br $br
    #     fi
    # done
}

function flush_iptables(){
    service iptables stop
    service iptables save
}

function force_quit(){
    ## in case qpidd can't stopped successfully
    ps aux | awk '/qpidd/ {print $2}' | xargs kill -9
}

function do_clean_work(){
    rm -rf /var/cache/yum
    yum clean all
    sleep 1
    yum clean all
}

function delete_vms_if_exists(){
    local vms=$(virsh list --all 2>/dev/null | awk '!/Name/ {print $2}')
    for vm in $vms
    do
        virsh destroy "$vm" 2>/dev/null
        virsh undefine "$vm" 2>/dev/null
    done
}

###########################
remove_stingray
remove_db2
flush_iptables
delete_ovs_bridge
delete_vms_if_exists

###########################
for service in ${services[@]}
do
    stop_service $service
done

##########################
for package in ${packages[@]}
do
    remove_package $package
done

for package in ${scepackages[@]}
do
    remove_package $package
done

##########################
for user in ${users[@]}
do
    userdel -r $user
done

##########################
for file in ${files[@]}
do
    remove_file $file
done

#########################
force_quit
do_clean_work
