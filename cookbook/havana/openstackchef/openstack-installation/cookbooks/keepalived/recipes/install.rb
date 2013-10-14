#
# Cookbook Name:: keepalived
# Recipe:: install
#
# Copyright 2013, IBM.
#

package "keepalived" do
  action :install
end

directory "/etc/keepalived/conf.d" do
  action :create
  owner "root"
  group "root"
  mode "0775"
end

template "/etc/keepalived/keepalived.conf" do
  source "keepalived.conf.erb"
  owner "root"
  group "root"
  mode 0644
end

service "keepalived" do
  supports :restart => true, :status => true
  action [:enable, :start]
  subscribes :restart, resources(:template => "/etc/keepalived/keepalived.conf"), :delayed
end
