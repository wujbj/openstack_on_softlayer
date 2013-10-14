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
 command "rm -rf /etc/my.cnf ; rm -rf /var/log/mysqld.log ; rm -rf /var/lib/mysql ; rm -rf /var/chef"
 action :run
end
