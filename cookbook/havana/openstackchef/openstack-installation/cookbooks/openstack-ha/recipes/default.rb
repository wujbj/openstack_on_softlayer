#
# Cookbook Name:: openstack-ha
# Recipe:: default
#
# Copyright 2013, IBM.
#

if node['ha_type'] == 'haproxy'
    include_recipe "openstack-ha::all-haproxy"
elsif node['ha_type'] == 'stingray'
    include_recipe "openstack-ha::all-stingray"
end
