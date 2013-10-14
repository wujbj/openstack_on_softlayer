#
# Author:: Salman Baset (sabaset@us.ibm.com)
# Cookbook Name:: yum
# Recipe:: rhel
#

yum_repository "rhel" do
  description "ISO Packages for Enterprise Linux"
#  key node['yum']['rhel']['key']
  url node['yum']['rhel']['url']
  enabled node['yum']['rhel']['enabled']
  action platform?('amazon') ? [:add, :update] : :add
end
