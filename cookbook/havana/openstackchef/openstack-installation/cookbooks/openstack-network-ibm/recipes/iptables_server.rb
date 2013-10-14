#
# Cookbook Name:: openstack-network-ibm
# Recipe:: iptables-server
#
# Copyright 2013, IBM
#
# All rights reserved - Do Not Redistribute
#
#
#
if node["iptables"]["enabled"] == true
  iptables_rule "port_quantumserver"
end
