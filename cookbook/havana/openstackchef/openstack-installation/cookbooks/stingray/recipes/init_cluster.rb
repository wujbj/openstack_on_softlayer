#
# Cookbook Name:: stingray
# Recipe:: init_cluster
#
# Copyright 2013, IBM
#
# All rights reserved - Do Not Redistribute
#

if node["iptables"]["enabled"] == true
    iptables_rule "port_stingray"
end

stingray "stingray" do
    url node['stingray']['url']
    action :install
end

stingray_init_cluster "cluster" do
    license_key node['stingray']['license_key']
    password node['stingray']['password']
end
