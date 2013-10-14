#
# Cookbook Name:: uninstall
# Recipe:: uninstall-nova-controller
# Author: Tao Tao (ttao@us.ibm.com) Bao Hua Dai(bhdai@cn.ibm.com)
#
# Remove OpenStack Nova Controller packages
#

#
# Stop nova-api service
#
service "openstack-nova-api" do
    action :stop
end

#
# Stop nova-scheduler service
#
service "openstack-nova-scheduler" do
    action :stop
end

#
# Stop nova-cert service
#
service "openstack-nova-cert" do
    action :stop
end

#
# Stop nova-consoleauth service
#
service "openstack-nova-consoleauth" do
    action :stop
end

#
# Restart dnsmasq service
#
service "dnsmasq" do
    action :restart
end

#
# Stop nova-vncproxy service
#
#service "openstack-nova-vncproxy" do
#    action :stop
#end

#
# Remove openstack-nova service
#
#yum_package "openstack-nova-*" do
#  action :remove
#  flush_cache [:after]
#end

#
# Remove the openstack nova scheduler package
#
execute "yum_remove_nova_scheduler" do
 command "yum remove -y openstack-nova-scheduler"
 action :run
end

#
# Remove the openstack nova novncproxy package
#
#execute "yum_remove_nova_novncproxy" do
# command "yum remove -y openstack-nova-novncproxy"
# action :run
#end

#
# Remove the openstack nova api package
#
execute "yum_remove_nova_api" do
 command "yum remove -y openstack-nova-api"
 action :run
end

#
# Remove the openstack nova cert package
#
execute "yum_remove_nova_cert" do
 command "yum remove -y openstack-nova-cert"
 action :run
end

#
# Remove the openstack nova console package
#
execute "yum_remove_nova_console" do
 command "yum remove -y openstack-nova-console"
 action :run
end

#
# Remove the openstack nova novnc package
#
execute "yum_remove_nova_novnc" do
 command "yum remove -y novnc"
 action :run
end

#
# Remove the openstack nova common package
#
execute "yum_remove_nova_common" do
 command "yum remove -y openstack-nova-common"
 action :run
end

#
# Remove the openstack nova utils package
#
execute "yum_remove_nova_utils" do
 command "yum remove -y openstack-utils"
 action :run
end

execute "yum_remove_python_nova" do
 command "yum remove -y python-nova*"
 action :run
end

execute "yum_remove_python_glance" do
 command "yum remove -y python-glance* ; yum -y remove python-nova* ; yum -y remove python-swift* ; yum -y remove python-keystone* ; yum -y remove python-glance* ; yum -y remove python-quantum* ; yum -y remove python-cinder*"
 action :run
end

execute "delete_nova_controller_repo" do
 command "rm -rf /var/log/nova/* ; rm -rf /var/lib/nova ; rm -rf /var/log/nova"
 action :run
end
#
# Delete the existing repo files
#
execute "yum_delete_repo" do
 command "cd /etc/yum.repos.d;ls * | egrep -v \"rbel|rhel|local\" | xargs rm -rf"
 action :run
end
