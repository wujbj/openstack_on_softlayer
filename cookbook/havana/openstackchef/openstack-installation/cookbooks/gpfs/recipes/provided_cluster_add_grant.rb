#
# Cookbook Name:: gpfs
# Recipe:: provided_cluster_add_grant
#
# On provided cluster, to configure auth and transfer this id_ras.pub to request cluster.
# 


execute "add_request_cluster_to_provided_cluster" do
  cwd "/var/mmfs/ssl"
  command "request_cluster_name=`ls request-* | awk -F '-' '{print $2}'` ; /usr/lpp/mmfs/bin/mmauth add ${request_cluster_name} -k request-${request_cluster_name}-id_rsa.pub"
  ignore_failure true
  action :run
end

execute "grant_auth_of_request_server_on_provided_cluster" do
  cwd "/var/mmfs/ssl"
  command "request_cluster_name=`ls request-*-id_rsa.pub | awk -F '-' '{print $2}'` ; /usr/lpp/mmfs/bin/mmauth grant ${request_cluster_name} -f /dev/#{node['gpfs']['gpfs_clusters']['provided_gpfs_device_name']}"
  ignore_failure true
  action :run
  not_if { node['gpfs']['gpfs_clusters']['provided_gpfs_device_name'].empty? }
end
#not_if { node['gpfs']['gpfs_clusters']['provided_gpfs_device_name'].nil? }

#execute "grant_auth_of_request_server_on_provided_cluster" do
#  command "request_cluster_name=`ls request-* | awk -F '-' '{print $2}'` ; mmauth grant $request_cluster_name -f /dev/#{node['gpfs']['gpfs_clusters']['provided_gpfs_device_name']}"
#  ignore_failure true
#  action :run
#  only_if { node['gpfs']['gpfs_clusters']['provided_gpfs_device_name'].nil? }
#end

execute "sleep_15_seconds" do
  command "sleep 15"
  ignore_failure true
  action :run
end


#execute "" do
#  command ""
#  ignore_failure true
#  action :run
#end
