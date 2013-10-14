#
# Cookbook Name:: gpfs
# Recipe:: gpfs
#
# Setup gpfs packages

gpfs_repository "gpfs" do
  description "gpfs"
  url node['gpfs']['gpfs_repo']['url']
  action platform?('amazon') ? [:add, :update] : :add
end

