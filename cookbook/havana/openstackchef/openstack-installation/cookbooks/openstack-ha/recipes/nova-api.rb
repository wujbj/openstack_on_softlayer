#
# Cookbook Name:: openstack-ha
# Recipe:: nova-api
#
# Copyright 2013, IBM.
#

if node["iptables"]["enabled"] == true
  iptables_rule "port_novaapi"
  iptables_rule "port_novametadata"
end

if node['ha_type'] == 'haproxy'
    include_recipe "openstack-ha::nova-api-haproxy"
elsif node['ha_type'] == 'stingray'
    include_recipe "openstack-ha::nova-api-stingray"
end
