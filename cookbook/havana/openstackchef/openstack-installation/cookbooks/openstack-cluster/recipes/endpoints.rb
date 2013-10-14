#
# Cookbook Name:: openstack-cluster
# Recipe:: endpoints
#

include_recipe "openstack-cluster::#{node['openstack']['ha']['service_type']}-endpoints"
