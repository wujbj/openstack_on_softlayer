#
# Cookbook Name:: gpfs
# Recipe:: request_cluster_add
#
# On request cluster, to add provided cluster to request cluster, add and mount provided file system to request cluster.
# 

execute "add_provided_cluster_name_on_request_cluster" do
  cwd "/var/mmfs/ssl"
  command "provided_cluster_name=`ls provided-*-id_rsa.pub | awk -F '-' '{print $2}'` ; /usr/lpp/mmfs/bin/mmremotecluster add ${provided_cluster_name} -n #{node['gpfs']['gpfs_clusters']['provided_cluster_nodes']} -k provided-${provided_cluster_name}-id_rsa.pub"
  ignore_failure true
  action :run
end

execute "add_provided_cluster_filesystem_on_request_cluster" do
  cwd "/var/mmfs/ssl"
  command "provided_cluster_name=`ls provided-*-id_rsa.pub | awk -F '-' '{print $2}'` ; /usr/lpp/mmfs/bin/mmremotefs add /dev/#{node['gpfs']['gpfs_clusters']['gpfs_device_name_on_request_cluster']} -f /dev/#{node['gpfs']['gpfs_clusters']['provided_gpfs_device_name']} -C ${provided_cluster_name} -A yes -T #{node['gpfs']['gpfs_clusters']['request_cluster_mount_point']} "
  ignore_failure true
  action :run
end

execute "sleep_5_seconds" do
  command "sleep 5"
  ignore_failure true
  action :run
end

puts "20130911---: node['gpfs']['gpfs_clusters']['request_cluster_nodes_need_mount']   ===> #{node['gpfs']['gpfs_clusters']['request_cluster_nodes_need_mount']}"
#if node['gpfs']['gpfs_clusters']['request_cluster_nodes_need_mount'].nil?
if node['gpfs']['gpfs_clusters']['request_cluster_nodes_need_mount'].empty?
  puts "it is null."
else
  puts "node['gpfs']['gpfs_clusters']['request_cluster_nodes_need_mount']   ===> #{node['gpfs']['gpfs_clusters']['request_cluster_nodes_need_mount']}"
end

##not_if { node['gpfs']['gpfs_clusters']['request_cluster_nodes_need_mount'].nil? }
execute "mount_provided_cluster_filesystem_on_specific_nodes_of_request_cluster" do
  command "/usr/lpp/mmfs/bin/mmmount /dev/#{node['gpfs']['gpfs_clusters']['gpfs_device_name_on_request_cluster']} -N #{node['gpfs']['gpfs_clusters']['request_cluster_nodes_need_mount']} "
  ignore_failure true
  action :run
  not_if do node['gpfs']['gpfs_clusters']['request_cluster_nodes_need_mount'].empty? end
end

execute "mount_provided_cluster_filesystem_on_request_cluster" do
  command "/usr/lpp/mmfs/bin/mmmount /dev/#{node['gpfs']['gpfs_clusters']['gpfs_device_name_on_request_cluster']} -a "
  ignore_failure true
  action :run
  only_if { node['gpfs']['gpfs_clusters']['request_cluster_nodes_need_mount'].empty? }
end

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
