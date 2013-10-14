# Cookbook Name:: openstack-block-storage-ibm
# # Recipe:: iptables
# #
# # Copyright 2013, IBM
# #
# # All rights reserved - Do Not Redistribute
# #
#
#
if node["iptables"]["enabled"] == true
  iptables_rule "port_cinderapi"
end
