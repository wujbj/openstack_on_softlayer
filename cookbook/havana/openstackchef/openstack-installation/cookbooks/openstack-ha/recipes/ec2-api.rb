#
# Cookbook Name:: openstack-ha
# Recipe:: ec2-api
#
# Copyright 2013, IBM.
#

if node["iptables"]["enabled"] == true
  iptables_rule "port_novaec2api"
end

if node['ha_type'] == 'haproxy'
    include_recipe "openstack-ha::ec2-api-haproxy"
elsif node['ha_type'] == 'stingray'
    include_recipe "openstack-ha::ec2-api-stingray"
end
