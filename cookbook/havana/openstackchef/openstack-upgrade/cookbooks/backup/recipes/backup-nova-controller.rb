#
# Cookbook Name:: backup
# Recipe:: backup-nova-controller
# Author: Tao Tao (ttao@us.ibm.com)
#
# Backup OpenStack Nova-related data and configuration
#

#
# Keep a copy of nova.conf file
#
execute "keep_nova_conf" do
 command "mkdir -p /tmp/nova;cp -f /etc/nova/nova.conf /tmp/nova/."
 action :run
 only_if { ::File.exists?("/etc/nova/nova.conf")}
end

