#!/bin/sh

yum remove -y openstack-nova-compute
yum remove -y openstack-nova-network
yum remove -y libvirt

service openstack-nova-cert stop
service openstack-nova-api stop
service openstack-nova-scheduler stop
service openstack-nova-consoleauth stop
service openstack-nova-novncproxy stop
yum remove -y openstack-nova-cert
yum remove -y openstack-nova-api
yum remove -y openstack-nova-scheduler
yum remove -y openstack-nova-console
yum remove -y openstack-nova-novncproxy
yum remove -y novnc
yum remove -y openstack-nova-common
yum remove -y openstack-utils
rm -rf /etc/nova
rm -rf /var/log/nova

service openstack-cinder-api stop
service openstack-cinder-scheduler stop
service openstack-cinder-volume stop
yum remove -y openstack-cinder
yum remove -y python-cinder
yum remove -y python-cinderclient
rm -rf /etc/cinder
rm -rf /var/log/cinder
vgremove cinder-volumes
losetup -d /dev/loop1

service tgtd stop
yum remove -y scsi-target-utils
yum remove -y openstack-cinder

service openstack-glance-api stop
service openstack-glance-registry stop
yum remove -y openstack-glance
rm -rf /etc/glance
rm -rf /var/log/glance
rm -rf /var/lib/glance

service qpidd stop
yum remove -y qpid-cpp-server

service openstack-keystone stop
yum remove -y openstack-keystone
rm -rf /etc/keystone
rm -rf /var/log/keystone

service mysqld stop
yum remove -y mysql-server
rm -rf /etc/my.cnf
rm -rf /var/lib/mysql

yum remove -y rabbitmq-server
rm ~/*.conf

rm ~/.my.cnf
