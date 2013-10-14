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
# Recipe:: uninstall-quantum
# Author: Bao Hua Dai (bhdai@cn.ibm.com)
# Function: Remove OpenStack quantum packages
#

# Stop quantum service
service "openstack-quantum" do
    action :stop
end
#service "openstack-glance-registry" do
#    action :stop
#end

#service "openstack-" do
#    action :stop
#end

#
# Remove the openstack quantum packages
#
execute "yum_remove_quantum" do
 command "yum remove -y openstack-quantum"
 action :run
end

#
# Remove the openstack python-quantum package
#
execute "yum_remove_python_quantum" do
 command "yum remove -y python-quantum* ; yum -y remove python-nova* ; yum -y remove python-swift* ; yum -y remove python-keystone* ; yum -y remove python-glance* ; yum -y remove python-quantum* ; yum -y remove python-cinder*"
 action :run
end

execute "delete_quantum" do
 command "rm -rf /etc/quantum ; rm -rf /var/log/quantum ; rm -rf /var/lib/quantum"
 action :run
end
