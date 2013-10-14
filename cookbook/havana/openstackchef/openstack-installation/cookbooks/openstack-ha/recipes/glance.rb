#
# Cookbook Name:: openstack-ha
# Recipe:: glance
#
# Copyright 2013, IBM.
#

if node["iptables"]["enabled"] == true
  iptables_rule "port_glanceapi"
  iptables_rule "port_glanceregistry"
end

if node['ha_type'] == 'haproxy'
    include_recipe "openstack-ha::glance-haproxy"
elsif node['ha_type'] == 'stingray'
    include_recipe "openstack-ha::glance-stingray"
end
