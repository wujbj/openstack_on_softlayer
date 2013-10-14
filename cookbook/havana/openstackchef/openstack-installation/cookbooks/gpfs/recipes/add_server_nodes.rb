#
# Cookbook Name:: gpfs
# Recipe:: add_nodes
#
# Add nodes to GPFS cluster.
# 
# Run this cookbook on any node in GPFS cluster, generally run it on master node.
#

execute "add_nodes_to_cluster" do
  command "cd /tmp/gpfs_working ; /usr/lpp/mmfs/bin/mmaddnode -N /tmp/gpfs_working/add_nodes ; cd - "
  ignore_failure true
  action :run
end

execute "apply_license_to_these_added_nodes" do
  command "cd /tmp/gpfs_working ; awk -F ':' '{print $1}' /tmp/gpfs_working/add_nodes | grep -v '#' | grep -v grep > /tmp/gpfs_working/add-server-nodes-list ; /usr/lpp/mmfs/bin/mmchlicense server --accept -N /tmp/gpfs_working/add-server-nodes-list ; cd - "
  ignore_failure true
  action :run
end

execute "start_GPFS_on_these_added_nodes" do
  command "cd /tmp/gpfs_working ; awk -F ':' '{print $1}' /tmp/gpfs_working/add_nodes | grep -v '#' | grep -v grep > /tmp/gpfs_working/add-server-nodes-list ; /usr/lpp/mmfs/bin/mmstartup -N /tmp/gpfs_working/add-server-nodes-list ; cd - "
  ignore_failure true
  action :run
end

execute "change_policy" do
  command "cd /tmp/gpfs_working ; /usr/lpp/mmfs/bin/mmchpolicy #{node['gpfs']['gpfs_device_name']} /tmp/gpfs_working/policy-definition ; cd - "
  ignore_failure true
  action :run
end

execute "add_autoload_attribute_to_added_nodes" do
  cwd "/tmp/gpfs_working"
  command "/usr/lpp/mmfs/bin/mmchconfig autoload=yes"
  ignore_failure true
  action :run
end

#execute "" do
#  command ""
#  ignore_failure true
#  action :run
#end
