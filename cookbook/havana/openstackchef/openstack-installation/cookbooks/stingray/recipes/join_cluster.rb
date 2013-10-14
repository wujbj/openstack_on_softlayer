#
# Cookbook Name:: stingray
# Recipe:: join_cluster
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

# get the stingray cluster master ip address
query = "(roles:init-cluster OR roles:stingray_init_cluster) AND chef_environment:#{node.chef_environment}"
result, _, _ = Chef::Search::Query.new.search(:node, query)
if result.length == 1
    master_ip = result[0]["ipaddress"]
else
    puts "==================================================="
    puts result[0]["ipaddress"]
    puts "ERROR to get the stingray cluster master ip address"
    puts "==================================================="
    exit
end

stingray_join_cluster "join_cluster" do
    cluster_host master_ip
    password node['stingray']['password']
end
