#
# Cookbook Name:: yum
# Recipe:: openstack
#
# Setup OpenStack packages

yum_repository "openstack" do
  description "OpenStack"
  url node['yum']['openstack']['url']
  enabled node['yum']['openstack']['enabled']
  action platform?('amazon') ? [:add, :update] : :add
end
