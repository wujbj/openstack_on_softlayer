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
# Recipe:: uninstall-keystone
# Author: Bao Hua Dai (bhdai@cn.ibm.com)
# Function: Remove OpenStack keystone packages
#

# Stop keystone service
service "openstack-keystone" do
    action :stop
end

#service "openstack-" do
#    action :stop
#end

#
# Remove the openstack keystone packages
#
execute "yum_remove_keystone" do
 command "yum remove -y openstack-keystone"
 action :run
end

#
# Remove the openstack python-keystone package
#
execute "yum_remove_python_keystone" do
 command "yum remove -y python-keystone* ; yum -y remove python-nova* ; yum -y remove python-swift* ; yum -y remove python-keystone* ; yum -y remove python-glance* ; yum -y remove python-quantum* ; yum -y remove python-cinder*"
 action :run
end

execute "delete_keystone_repo" do
 command "rm -rf /etc/keystone ; rm -rf /var/log/keystone ; rm -rf /var/lib/keystone"
 action :run
end
