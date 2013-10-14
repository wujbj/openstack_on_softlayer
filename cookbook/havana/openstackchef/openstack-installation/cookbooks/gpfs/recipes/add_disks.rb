#
# Cookbook Name:: gpfs
# Recipe:: add_disks
#
# Add disks to GPFS cluster.
# 
# Run this cookbook on any node in GPFS cluster, generally run it on master node.
#

execute "generate_nsd_for_new_disks" do
  command "cd /tmp/gpfs_working ; /usr/lpp/mmfs/bin/mmcrnsd -F /tmp/gpfs_working/add_disks -v no ; cd - "
  ignore_failure true
  action :run
end

# When add disks which on the nodes that have existed in GPFS cluster, we do not need add these nodes to cluster.
# When add disks which on the nodes that have not existed in GPFS cluster, we need add these nodes to cluster.
# command "cd /tmp/gpfs_working ; if [ -f /tmp/gpfs_working/add_nodes ] ; then /usr/lpp/mmfs/bin/mmadddisk #{node['gpfs']['gpfs_device_name']} -F /tmp/gpfs_working/add_disks -r -v no -N /tmp/gpfs_working/add_new_nodes ; else /usr/lpp/mmfs/bin/mmadddisk #{node['gpfs']['gpfs_device_name']} -F /tmp/gpfs_working/add_disks -r -v no ; fi ; cd - "
execute "add_disks_to_filesystem" do
  command "cd /tmp/gpfs_working ; /usr/lpp/mmfs/bin/mmadddisk #{node['gpfs']['gpfs_device_name']} -F /tmp/gpfs_working/add_disks -r -v no ; cd - "
  ignore_failure true
  action :run
end

#execute "" do
#  command ""
#  ignore_failure true
#  action :run
#end
