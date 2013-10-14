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
# Recipe:: uninstall-swift
# Author: Bao Hua Dai (bhdai@cn.ibm.com)
# Function: Remove OpenStack swift packages
#

# Stop swift service
service "openstack-swift" do
    action :stop
end
#service "openstack-glance-registry" do
#    action :stop
#end

#service "openstack-" do
#    action :stop
#end

#
# Remove the openstack swift packages
#
execute "yum_remove_swift" do
 command "yum remove -y openstack-swift"
 action :run
end

#
# Remove the openstack python-swift package
#
execute "yum_remove_python_swift" do
 command "yum remove -y python-swift*"
 action :run
end

execute "yum_remove_python_glance" do
 command "yum remove -y python-glance* ; yum -y remove python-nova* ; yum -y remove python-swift* ; yum -y remove python-keystone* ; yum -y remove python-glance* ; yum -y remove python-quantum* ; yum -y remove python-cinder*"
 action :run
end

execute "delete_swift" do
 command "rm -rf /etc/swift ; rm -rf /var/log/swift ; rm -rf /var/lib/swift"
 action :run
end
