#
# Cookbook Name:: uninstall
# Recipe:: uninstall-keystone
# Author: Bao Hua Dai (bhdai@cn.ibm.com)
# Function: Remove OpenStack keystone packages
#

# Stop keystone service
service "openstack-keystone" do
    action :stop
end

#service "openstack-" do
#    action :stop
#end

#
# Remove the openstack keystone packages
#
execute "yum_remove_keystone" do
 command "yum remove -y openstack-keystone"
 action :run
end

#
# Remove the openstack python-keystone package
#
execute "yum_remove_python_keystone" do
 command "yum remove -y python-keystone*"
 action :run
end

execute "delete_keystone_repo" do
 command "rm -rf /etc/keystone ; rm -rf /var/log/keystone"
 action :run
end
