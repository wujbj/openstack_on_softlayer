#
# Cookbook Name:: gpfs
# Recipe:: shutdown
#
# Shutdown GPFS cluster.
# 
# Run this cookbook on Master-node only
#
execute "umount_GPFS_filesystem" do
  command "/usr/lpp/mmfs/bin/mmumount all -a"
  ignore_failure true
  action :run
end

execute "sleep_10_seconds" do
  command "sleep 10"
  ignore_failure true
  action :run
end

execute "shutdown_GPFS_cluster" do
  command "/usr/lpp/mmfs/bin/mmshutdown -a"
  ignore_failure true
  action :run
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
