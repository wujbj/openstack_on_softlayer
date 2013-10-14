#
# Cookbook Name:: restore
# Recipe:: restore-cinder-volume
# Author: Tao Tao (ttao@us.ibm.com)
#
# Restore OpenStack Cinder-related data and configuration
#

#
# Restore cinder.conf
#
execute "restore_cinder_conf" do
 command "unalias -a;cp -f /tmp/cinder/cinder.conf /etc/cinder/."
 action :run
end

execute "restore_tgt_conf" do
 command "unalias -a;cp -f /tmp/tgt/conf.d/cinder.conf /etc/tgt/conf.d/."
 action :run
end

service "tgtd" do
    action :restart
end

service "iscsi" do
    action :restart
end

#
# Restart cinder-api service
#
service "openstack-cinder-api" do
    action :restart
end

#
# Restart cinder-volume service
#
service "openstack-cinder-volume" do
    action :restart
end
