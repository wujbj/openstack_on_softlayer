#
# Cookbook Name:: backup
# Recipe:: backup-cinder-volume
# Author: Tao Tao (ttao@us.ibm.com)
#
# Backup OpenStack Cinder related data and configuration
#

#
# Keep a copy of nova.conf file
#
execute "keep_cinder_conf" do
 command "mkdir -p /tmp/cinder;cp /etc/cinder/cinder.conf /tmp/cinder/."
 action :run
end

execute "keep_tgt_conf" do
 command "mkdir -p /tmp/tgt;cp -Rp /etc/tgt/* /tmp/tgt/."
 action :run
end

service "openstack-cinder-api" do
    action :restart
end

service "openstack-cinder-volume" do
    action :restart
end
