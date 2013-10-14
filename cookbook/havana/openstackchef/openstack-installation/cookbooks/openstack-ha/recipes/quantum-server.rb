#
# Cookbook Name:: openstack-ha
# Recipe:: quantum
#
# Copyright 2013, IBM.
#

if node["iptables"]["enabled"] == true
  iptables_rule "port_quantumserver"
end

if node['ha_type'] == 'haproxy'
    include_recipe "openstack-ha::quantum-server-haproxy"
elsif node['ha_type'] == 'stingray'
    include_recipe "openstack-ha::quantum-server-stingray"
end
