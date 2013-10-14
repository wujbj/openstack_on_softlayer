#
# Cookbook Name:: openstack-ha
# Recipe:: cinder
#
# Copyright 2013, IBM.
#

if node["iptables"]["enabled"] == true
  iptables_rule "port_cinderapi"
end

if node['ha_type'] == 'haproxy'
    include_recipe "openstack-ha::cinder-api-haproxy"
elsif node['ha_type'] == 'stingray'
    include_recipe "openstack-ha::cinder-api-stingray"
end
