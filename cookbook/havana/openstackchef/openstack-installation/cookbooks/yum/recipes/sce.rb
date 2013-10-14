#
# Cookbook Name:: yum
# Recipe:: sce
#
# Setup SCE packages

yum_repository "sce" do
  description "sce"
  url node['yum']['sce']['url']
  enabled node['yum']['sce']['enabled']
  action platform?('amazon') ? [:add, :update] : :add
end
