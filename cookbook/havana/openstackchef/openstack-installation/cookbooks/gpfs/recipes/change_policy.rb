#
# Cookbook Name:: gpfs
# Recipe:: apply_policy
#
# Apply policy to GPFS cluster.
# 
# Run this cookbook on Master-node only
#
execute "change_policy" do
  command "cd /tmp/gpfs_working ; /usr/lpp/mmfs/bin/mmchpolicy #{node['gpfs']['gpfs_device_name']} /tmp/gpfs_working/change_policy_definition ; cd - "
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
