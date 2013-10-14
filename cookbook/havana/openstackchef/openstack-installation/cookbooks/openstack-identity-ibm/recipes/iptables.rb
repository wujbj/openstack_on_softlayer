#
# Cookbook Name:: openstack-image-ibm
# Recipe:: iptables
#
# Copyright 2013, IBM
#
# All rights reserved - Do Not Redistribute
#


if node["iptables"]["enabled"] == true
  iptables_rule "port_keystone"
end
