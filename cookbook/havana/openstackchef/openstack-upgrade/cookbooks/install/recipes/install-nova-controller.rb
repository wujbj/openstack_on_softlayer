#
# Cookbook Name:: install
# Recipe:: install-nova-controller
# Author: Tao Tao (ttao@us.ibm.com)
#
# Install OpenStack Nova Controller packages
#
#include_recipe "yum::rhel"
#include_recipe "yum::epel"
#include_recipe "yum::openstack"


execute "yum_change_repo" do
 command "rpm -e epel-release-6-8.noarch;rpm -Uvh http://download.fedoraproject.org/pub/epel/6/i386/epel-release-6-8.noarch.rpm" 
 action :run
 not_if { ::File.exists?("/etc/yum.repos.d/epel.repo")}
end

#yum_package "openstack-nova" do 
#  action :install
#  flush_cache [:before]
#end

#
# Install nova scheduler
#
execute "yum_install_nova_scheduler" do
 command "yum install -y openstack-nova-scheduler"
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
# Install nova novncproxy
#
#execute "yum_install_nova_novncproxy" do
# command "yum install -y openstack-nova-novncproxy"
# action :run
#end

#
# Install nova cert 
#
execute "yum_install_nova_cert" do
 command "yum install -y openstack-nova-cert"
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

