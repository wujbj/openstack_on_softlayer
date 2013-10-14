#
# Cookbook Name:: openstack-ha
# Recipe:: init-cluster
#
# Copyright 2013, IBM.
#

if node['ha_type'] == 'haproxy'
    include_recipe "keepalived::install"
    include_recipe "haproxy::install"
elsif node['ha_type'] == 'stingray'
    include_recipe "stingray::init_cluster"
end
