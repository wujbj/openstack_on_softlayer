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
# Recipe:: uninstall-qpid
# Author: Bao Hua Dai (bhdai@cn.ibm.com)
# Function: Remove OpenStack qpid packages
#

# Stop qpid service
service "qpidd" do
    action :stop
end

#service "openstack-" do
#    action :stop
#end

#
# Remove the openstack qpid packages
#
execute "yum_remove_qpid" do
 command "yum remove -y qpid-cpp-server"
 action :run
end

#
# Remove the openstack python-qpid package
#
execute "yum_remove_python_qpid" do
 command "yum remove -y python-qpid* ; yum -y remove python-nova* ; yum -y remove python-swift* ; yum -y remove python-keystone* ; yum -y remove python-glance* ; yum -y remove python-quantum* ; yum -y remove python-cinder*"
 action :run
end

execute "delete_qpid" do
 command "rm -rf /etc/qpid ; rm -rf /etc/qpidd.conf* ; rm -rf /var/lib/qpidd"
 action :run
end
