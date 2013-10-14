#
# Cookbook Name:: openstack-compute-ibm
# Recipe:: iptables-ec2api
#
# Copyright 2013, IBM
#
# All rights reserved - Do Not Redistribute
#
#
#

if node["iptables"]["enabled"] == true
  iptables_rule "port_novaec2api"
end
