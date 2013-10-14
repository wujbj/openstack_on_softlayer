#
# Cookbook Name:: gpfs
# Recipe:: apply_policy
#
# Apply policy to GPFS cluster.
# 
# Run this cookbook on Master-node only
#
execute "apply_policy" do
  command "cd /tmp/gpfs_working ; /usr/lpp/mmfs/bin/mmapplypolicy #{node['gpfs']['gpfs_device_name']} -P /tmp/gpfs_working/policy_definition -N /tmp/gpfs_working/apply_policy_nodes ; cd - "
  ignore_failure true
  action :run
end

execute "sleep_45_seconds" do
  command "sleep 45"
  ignore_failure true
  action :run
end

#execute "" do
#  command ""
#  ignore_failure true
#  action :run
#end
