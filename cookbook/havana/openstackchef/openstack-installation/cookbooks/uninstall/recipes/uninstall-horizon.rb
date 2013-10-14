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
# Recipe:: uninstall-horizon
# Author: Bao Hua Dai (bhdai@cn.ibm.com)
# Function: Remove OpenStack horizon packages
#

# Stop keystone service
service "openstack-horizon" do
    action :stop
end
service "openstack-dashboard" do
    action :stop
end

#service "openstack-" do
#    action :stop
#end

#
# Remove the openstack horizon packages
#
execute "yum_remove_horizon" do
 command "yum remove -y openstack-horizon ; yum remove -y openstack-dashboard"
 action :run
end

#
# Remove the openstack python-horizon package
#
execute "yum_remove_python_horizon" do
 command "yum remove -y python-horizon* ; yum remove -y python-dashboard* ; yum -y remove python-nova* ; yum -y remove python-swift* ; yum -y remove python-keystone* ; yum -y remove python-glance* ; yum -y remove python-quantum* ; yum -y remove python-cinder*"
 action :run
end

execute "delete_keystone_repo" do
 command "rm -rf /etc/horizon ; rm -rf /var/log/horizon ; rm -rf /var/lib/horizon ; rm -rf /etc/dashboard ; rm -rf /var/log/dashboard ; rm -rf /var/lib/dashboard"
 action :run
end
