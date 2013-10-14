#
# Cookbook Name:: gpfs
# Recipe:: provided_cluster_auth
#
# On provided cluster, to configure auth and transfer this id_ras.pub to request cluster.
# 

# will generate id_rsa.pub and openssl.conf under /var/mmfs/ssl.
# We can obtain cluster name from openssl.conf accroding to commonName attribute.
execute "generate_auth_key_on_provided_cluster-#{node['gpfs']['gpfs_clusters']['provided_cluster_master']}" do
  command "/usr/lpp/mmfs/bin/mmauth genkey new"
  ignore_failure true
  action :run
end

execute "shutdown_provided_cluster-#{node['gpfs']['gpfs_clusters']['provided_cluster_master']}" do
  command "/usr/lpp/mmfs/bin/mmshutdown -a"
  ignore_failure true
  action :run
end

execute "sleep_15_seconds" do
  command "sleep 15"
  ignore_failure true
  action :run
end

execute "apply_auth_update_on_provided_cluster-#{node['gpfs']['gpfs_clusters']['provided_cluster_master']}" do
  command "/usr/lpp/mmfs/bin/mmauth update . -l AUTHONLY"
  ignore_failure true
  action :run
end

execute "sleep_5_seconds" do
  command "sleep 5"
  ignore_failure true
  action :run
end

execute "startup_provided_cluster-#{node['gpfs']['gpfs_clusters']['provided_cluster_master']}" do
  command "/usr/lpp/mmfs/bin/mmstartup -a"
  ignore_failure true
  action :run
end

#only_if { File.exists?("/var/mmfs/ssl/id_rsa_committed.pub") }
execute "transfer_id_ras_from_provided_server_to_request_cluster" do
  command "provided_cluster_name=`/usr/lpp/mmfs/bin/mmlscluster |grep 'GPFS cluster name:' | awk  '{print $4}'` ; cp /var/mmfs/ssl/id_rsa.pub /var/mmfs/ssl/provided-${provided_cluster_name}-id_rsa.pub ; scp -o StrictHostKeyChecking=no /var/mmfs/ssl/provided-${provided_cluster_name}-id_rsa.pub #{node['gpfs']['gpfs_clusters']['request_cluster_master']}:/var/mmfs/ssl/."
  ignore_failure true
  action :run
end


#execute "" do
#  command ""
#  ignore_failure true
#  action :run
#end
