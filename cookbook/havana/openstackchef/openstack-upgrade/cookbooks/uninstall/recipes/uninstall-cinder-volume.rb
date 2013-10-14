#
# Cookbook Name:: uninstall
# Recipe:: uninstall-cinder-volume
# Author: Tao Tao (ttao@us.ibm.com) Bao Hua Dai(bhdai@cn.ibm.com)
# 
# Remove OpenStack Cinder volume packages
#

service "openstack-cinder-api" do
    action :stop
end

service "openstack-cinder-volume" do
    action :stop
end

service "openstack-nova-scheduler" do
    action :stop
end

#yum_package "openstack-nova-*" do
#  action :remove
#  flush_cache [:after]
#end

#
# Remove the openstack cinder package
#
execute "yum_remove_cinder" do
 command "yum remove -y openstack-cinder-*"
 action :run
end

#
# Remove the openstack cinder package
#
execute "yum_remove_python" do
 command "yum remove -y python-cinder*"
 action :run
end

execute "yum_delete_repo" do
 command "cd /etc/yum.repos.d;ls * | egrep -v \"rbel|rhel|local\" | xargs rm -rf"
 action :run
end

execute "yum_delete_cinder_repo" do
 command "rm -rf /etc/cinder ; rm -rf /var/log/cinder"
 action :run
end

execute "delete_cinder_vg" do
 command "vgremove cinder-volumes ; losetup -d /dev/loop1"
 action :run
end

#yum_package "openstack-nova" do 
#  action :install
#  flush_cache [:before]
#end