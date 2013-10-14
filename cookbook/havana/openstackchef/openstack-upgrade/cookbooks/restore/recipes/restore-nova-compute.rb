#
# Cookbook Name:: restore
# Recipe:: restore-nova-compute
# Author: Tao Tao (ttao@us.ibm.com)
#
# Restore OpenStack Nova-related data and configuration
#

#
# Restore nova.conf
#
execute "restore_nova_conf" do
 command "unalias -a;cp -f /tmp/nova/nova.conf /etc/nova/."
 action :run
end

#
# Restart nova-api service
#
service "openstack-nova-api" do
    action :restart
end

#
# Restart nova-network service
#
service "openstack-nova-network" do
    action :restart
end

#
# Restart nova-compute service
#
service "openstack-nova-compute" do
    action :restart
end
