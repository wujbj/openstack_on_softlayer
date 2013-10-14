#
# Cookbook Name:: install
# Recipe:: install-nova-compute
# Author: Tao Tao (ttao@us.ibm.com)
#
# Install OpenStack Nova Compute packages
#
#include_recipe "yum::rhel"
#include_recipe "yum::epel"
#include_recipe "yum::openstack"


#execute "yum_change_repo" do
# command "rpm -e epel-release-6-8.noarch;rpm -Uvh http://download.fedoraproject.org/pub/epel/6/i386/epel-release-6-8.noarch.rpm" 
# action :run
# not_if { ::File.exists?("/etc/yum.repos.d/epel.repo")}
#end

#yum_package "openstack-nova" do 
#  action :install
#  flush_cache [:before]
#end

#
# Install nova compute
#
execute "yum_install_nova_compute" do
 command "yum install -y openstack-nova-compute"
 action :run
end

#
# Install nova network
#
execute "yum_install_nova_network" do
 command "yum install -y openstack-nova-network"
 action :run
end

#
# Install nova api
#
execute "yum_install_nova_api" do
 command "yum install -y openstack-nova-api"
 action :run
end

#
# Install dnsmasq
#
#execute "yum_install_dnsmasq" do
# command "yum install -y dnsmasq"
# action :run
#end

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
