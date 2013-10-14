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
 command "yum remove -y python-qpid*"
 action :run
end

execute "delete_qpid" do
 command "rm -rf /etc/qpid ; rm -rf /etc/qpidd.conf*"
 action :run
end
