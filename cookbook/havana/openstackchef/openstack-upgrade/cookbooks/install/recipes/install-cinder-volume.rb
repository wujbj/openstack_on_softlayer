#
# Cookbook Name:: install
# Recipe:: install-cinder-volume
# Author: Tao Tao (ttao@us.ibm.com)
#
# Install OpenStack Cinder Volume packages
#
#include_recipe "yum::rhel"
#include_recipe "yum::epel"
#include_recipe "yum::openstack"

#execute "yum_change_repo" do
# command "rpm -e epel-release-6-8.noarch;rpm -Uvh http://download.fedoraproject.org/pub/epel/6/i386/epel-release-6-8.noarch.rpm" 
# action :run
# not_if { ::File.exists?("/etc/yum.repos.d/epel.repo")}
#end

#yum_package "openstack-cinder" do 
#  action :install
#  flush_cache [:before]
#end

#
# Install cinder volume
#
execute "yum_install_cinder_volume" do
 command "yum install -y openstack-cinder"
 action :run
end

volume_size = node["cinder"]["volume_group_size"]
seek_count = volume_size.delete("G").to_i * 1024
seek_count = 40 * 1024 if seek_count == 0

execute "Create Cinder volume group" do
  command "if [ ! -d /var/lib/cinder ] ; then  mkdir -p /var/lib/cinder ; fi ; dd if=/dev/zero of=/var/lib/cinder/cinder-volumes.img bs=1M seek=#{seek_count} count=0; vgcreate --verbose cinder-volumes `losetup --show -f /var/lib/cinder/cinder-volumes.img`"
  action :run
  not_if "vgscan | grep cinder-volumes"
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
#
# Restart cinder-scheduler service
#
service "openstack-cinder-scheduler" do
    action :restart
end
