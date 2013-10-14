#
# Cookbook Name:: openstack-ha
# Recipe:: keystone
#
# Copyright 2013, IBM.
#

if node["iptables"]["enabled"] == true
    iptables_rule "port_keystone"
end

if node['ha_type'] == 'haproxy'
    include_recipe "openstack-ha::keystone-haproxy"
elsif node['ha_type'] == 'stingray'
    include_recipe "openstack-ha::keystone-stingray"
end
