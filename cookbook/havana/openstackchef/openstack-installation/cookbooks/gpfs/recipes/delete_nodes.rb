#
# Cookbook Name:: gpfs
# Recipe:: delete_nodes
#
# Delete nodes to GPFS cluster.
# 
# Run this cookbook on any node in GPFS cluster, generally run it on master node.
#

execute "unmount_all_GPFS_filesystem" do
  command " /usr/lpp/mmfs/bin/mmumount all -a "
  ignore_failure true
  action :run
end

execute "shutdown_GPFS_service" do
  command "/usr/lpp/mmfs/bin/mmshutdown -N /tmp/gpfs_working/delete_nodes"
  ignore_failure true
  action :run
end

# do not think about quorum mode for deletion nodes
# do not think about NSD server mode for deletion nodes
execute "delete_nodes_to_cluster" do
  command "cd /tmp/gpfs_working ; /usr/lpp/mmfs/bin/mmdelnode -N /tmp/gpfs_working/delete_nodes ; cd - "
  ignore_failure true
  action :run
end

execute "mount_GPFS_filesystem" do
  command "/usr/lpp/mmfs/bin/mmmount all -a "
  ignore_failure true
  action :run
end

#execute "" do
#  command ""
#  ignore_failure true
#  action :run
#end
