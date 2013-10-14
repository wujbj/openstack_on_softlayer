#
# Cookbook Name:: openstack-ops-messaging-ibm
# Recipe:: default
#
# Copyright 2013, IBM
#
# All rights reserved - Do Not Redistribute
#

if node["iptables"]["enabled"] == true
  iptables_rule "port_qpid"
end

