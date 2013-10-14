#
# Cookbook Name:: gpfs
# Recipe:: delete_disks
#
# Delete disks to GPFS cluster.
# 
# Run this cookbook on any node in GPFS cluster, generally run it on master node.
#

# input nsd name as disk name
# 
execute "delete_disks_from_GPFS_filesystem" do
  command " cd /tmp/gpfs_working ; /usr/lpp/mmfs/bin/mmdeldisk #{node['gpfs']['gpfs_device_name']}  -F /tmp/gpfs_working/delete_disks ; cd -  "
  ignore_failure true
  action :run
end

execute "delete_disks_from_GPFS_filesystem" do
  command " cd /tmp/gpfs_working ; /usr/lpp/mmfs/bin/mmdelnsd -F /tmp/gpfs_working/delete_disks ; cd -  "
  ignore_failure true
  action :run
end

#execute "" do
#  command ""
#  ignore_failure true
#  action :run
#end
