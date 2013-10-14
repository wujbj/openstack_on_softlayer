#
# Cookbook Name:: openstack-compute-ibm
# Recipe:: iptables-vncproxy
#
# Copyright 2013, IBM
#
# All rights reserved - Do Not Redistribute
#
#
#

if node["iptables"]["enabled"] == true
  iptables_rule "port_vncproxy"
end


