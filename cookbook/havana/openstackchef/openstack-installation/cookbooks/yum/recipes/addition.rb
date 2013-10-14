#
# Cookbook Name:: yum
# Recipe:: addition
#
# Setup additional packages

yum_repository "addition" do
  description "Additional Packages"
  url node['yum']['addition']['url']
  enabled node['yum']['addition']['enabled']
  action platform?('amazon') ? [:add, :update] : :add
end
