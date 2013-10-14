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
# Recipe:: uninstall-mysql
# Author: Bao Hua Dai (bhdai@cn.ibm.com)
# Function: Remove mysql packages
#

# Stop mysql service
service "mysqld" do
    action :stop
end

#service "openstack-" do
#    action :stop
#end

#
# Remove the mysql packages
#
execute "yum_remove_mysql" do
 command "yum remove -y mysql-server ; yum remove -y mysql"
 action :run
end

#
# Remove the openstack python-qpid package
#
#execute "yum_remove_python_qpid" do
# command "yum remove -y python-qpid*"
# action :run
#end

execute "delete_mysql" do
 command "rm -rf /etc/my.cnf ; rm -rf /var/log/mysqld.log ; rm -rf /var/lib/mysql ; rm -rf /var/chef ; rm -rf ~/.my.cnf"
 action :run
end
