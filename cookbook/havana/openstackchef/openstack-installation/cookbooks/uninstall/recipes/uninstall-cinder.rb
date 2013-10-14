#/******************************************************* {COPYRIGHT} ***
# * Licensed Materials - Property of IBM
# *
# * 5725-C88
# *
# * (C) Copyright IBM Corp. 2012, 2013 All Rights Reserved
# *
# * US Government Users Restricted Rights - Use, duplication or
# * disclosure restricted by GSA ADP Schedule Contract with
# * IBM Corp.
#******************************************************* {COPYRIGHT} ***/
#
# Cookbook Name:: uninstall
# Recipe:: uninstall-cinder
# Author: Tao Tao (ttao@us.ibm.com) Bao Hua Dai(bhdai@cn.ibm.com)
# 
# Remove OpenStack Cinder volume packages
#

service "openstack-cinder-api" do
    action :stop
end

service "openstack-cinder-volume" do
    action :stop
end

service "openstack-nova-scheduler" do
    action :stop
end

#yum_package "openstack-nova-*" do
#  action :remove
#  flush_cache [:after]
#end

#
# Remove the openstack cinder package
#
execute "yum_remove_cinder" do
 command "yum remove -y openstack-cinder-*"
 action :run
 ignore_failure true
end

#
# Remove the openstack cinder package
#
execute "yum_remove_python" do
 command "yum remove -y python-cinder* ; yum -y remove python-nova* ; yum -y remove python-swift* ; yum -y remove python-keystone* ; yum -y remove python-glance* ; yum -y remove python-quantum*"
 action :run
 ignore_failure true
end

#execute "yum_delete_repo" do
# command "cd /etc/yum.repos.d;ls * | egrep -v \"rbel|rhel|local\" | xargs rm -rf"
# action :run
#end

execute "delete_cinder_vg" do
 command "if [ -f /var/lib/cinder/cinder-volumes.img ] ; then vgremove cinder-volumes ; fi ; losetup -d `losetup -a | awk '{if(substr($3,2,length($3)-2) == \"/var/lib/cinder/cinder-volumes.img\") printf(\"%s\\n\",substr($1,1,length($1)-1))}'`"
 action :run
 ignore_failure true
end

execute "yum_delete_cinder_repo" do
 command "rm -rf /etc/cinder ; rm -rf /var/log/cinder"
 action :run
 ignore_failure true
end

execute "yum_delete_cinder_log" do
 command "rm -rf /var/log/cinder ; rm -rf /var/lib/cinder"
 action :run
 ignore_failure true
end


#yum_package "openstack-nova" do 
#  action :install
#  flush_cache [:before]
#end
