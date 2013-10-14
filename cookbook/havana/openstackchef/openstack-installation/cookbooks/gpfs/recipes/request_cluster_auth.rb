#
# Cookbook Name:: gpfs
# Recipe:: request_cluster_auth
#
# On request cluster, to configure auth and transfer this id_ras.pub to provided cluster.
# 

# will generate id_rsa.pub and openssl.conf under /var/mmfs/ssl.
# We can obtain cluster name from openssl.conf accroding to commonName attribute.
execute "generate_auth_key_on_request_cluster-#{node['gpfs']['gpfs_clusters']['request_cluster_master']}" do
  command "/usr/lpp/mmfs/bin/mmauth genkey new"
  ignore_failure true
  action :run
end

execute "shutdown_request_cluster-#{node['gpfs']['gpfs_clusters']['request_cluster_master']}" do
  command "/usr/lpp/mmfs/bin/mmshutdown -a"
  ignore_failure true
  action :run
end

execute "sleep_15_seconds" do
  command "sleep 15"
  ignore_failure true
  action :run
end

execute "apply_auth_update_on_request_cluster-#{node['gpfs']['gpfs_clusters']['request_cluster_master']}" do
  command "/usr/lpp/mmfs/bin/mmauth update . -l AUTHONLY"
  ignore_failure true
  action :run
end

execute "sleep_5_seconds" do
  command "sleep 5"
  ignore_failure true
  action :run
end

execute "startup_request_cluster-#{node['gpfs']['gpfs_clusters']['request_cluster_master']}" do
  command "/usr/lpp/mmfs/bin/mmstartup -a"
  ignore_failure true
  action :run
end

execute "transfer_id_ras_from_request_cluster_to_provided_cluster" do
  command "request_cluster_name=`/usr/lpp/mmfs/bin/mmlscluster |grep 'GPFS cluster name:' | awk  '{print $4}'` ; cp /var/mmfs/ssl/id_rsa.pub /var/mmfs/ssl/request-${request_cluster_name}-id_rsa.pub ; scp -o StrictHostKeyChecking=no /var/mmfs/ssl/request-${request_cluster_name}-id_rsa.pub #{node['gpfs']['gpfs_clusters']['provided_cluster_master']}:/var/mmfs/ssl/."
  ignore_failure true
  action :run
end

#execute "" do
#  command ""
#  ignore_failure true
#  action :run
#end
