#
# Cookbook Name:: gpfs
# Recipe:: restart
#
# After upgrading GPFS and restart GPFS cluster.
# 
# Run this cookbook on Master-node only
#

#execute "apply_GPFS_license" do
#  command "source $HOME/.bash_profile ; /usr/lpp/mmfs/bin/mmchlicense server --accept -N all"
#  ignore_failure true
#  action :run
#end

execute "start_GPFS_cluster" do
  command "source $HOME/.bash_profile ; /usr/lpp/mmfs/bin/mmstartup -a "
  ignore_failure true
  action :run
end

execute "sleep_15_seconds" do
  command "sleep 15"
  ignore_failure true
  action :run
end

execute "mount_GPFS_filesystem" do
  command "source $HOME/.bash_profile ; /usr/lpp/mmfs/bin/mmmount all -a"
  ignore_failure true
  action :run
end

#execute "" do
#  command ""
#  ignore_failure true
#  action :run
#end
