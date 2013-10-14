#
# Cookbook Name:: uninstall
# Recipe:: uninstall-nova-compute 
# Author: Tao Tao (ttao@us.ibm.com) Bao Hua Dai(bhdai@cn.ibm.com)
# Function: Uninstall nova-comopute components
#
# Remove OpenStack Nova Compute packages
#

#
# Stop nova-api service
#
service "openstack-nova-api" do
    action :stop
end

#
# Stop nova-compute service
#
service "openstack-nova-compute" do
    action :stop
end

#
# Stop nova-network service
#
service "openstack-nova-network" do
    action :stop
end

#
# Remove openstack-nova service
#
#yum_package "openstack-nova-*" do
#  action :remove
#  flush_cache [:after]
#end

#
# Remove the openstack nova compute package
#
execute "yum_remove_nova_compute" do
 command "yum remove -y openstack-nova-compute"
 #command "yum remove -y openstack-nova-network"
 action :run
end

#
# Remove the openstack nova network package
#
execute "yum_remove_nova_network" do
 command "yum remove -y openstack-nova-network"
 action :run
end

execute "delete_nova_compute_repo" do
 command "rm -rf /var/log/nova/* ; rm -rf /var/lib/nova/instances/* ; rm -rf /var/log/nova"
 action :run
end

#
# Delete the existing repo files
#
execute "yum_delete_repo" do
 command "cd /etc/yum.repos.d;ls * | egrep -v \"rbel|rhel|local\" | xargs rm -rf"
 action :run
end
