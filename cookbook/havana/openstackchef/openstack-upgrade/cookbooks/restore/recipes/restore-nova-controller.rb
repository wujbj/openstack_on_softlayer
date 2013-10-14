#
# Cookbook Name:: restore
# Recipe:: restore-nova-controller
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
# Restart nova-scheduler service
#
service "openstack-nova-scheduler" do
    action :restart
end

#
# Restart nova-cert service
#
service "openstack-nova-cert" do
    action :restart
end

#
# Restart nova-vncproxy service
#
#service "openstack-nova-vncproxy" do
#    action :restart
#end

