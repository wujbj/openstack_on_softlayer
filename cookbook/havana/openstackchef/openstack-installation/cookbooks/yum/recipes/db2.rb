#
# Cookbook Name:: yum
# Recipe:: db2
#
# Setup db2 packages

yum_repository "db2" do
  description "DB2"
  url node['yum']['db2']['url']
  enabled node['yum']['db2']['enabled']
  action platform?('amazon') ? [:add, :update] : :add
end
