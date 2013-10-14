#
# Cookbook Name:: gpfs
# Recipe:: stop
#
# Stop GPFS cluster.
# 

execute "obtain_all_nodesname_from_GPFS_cluster" do
  command " if [ -d /tmp/gpfs_working ] ; then rm -rf /tmp/gpfs_working ; mkdir -p /tmp/gpfs_working ; else mkdir -p /tmp/gpfs_working ; fi ; /usr/lpp/mmfs/bin/mmlsnode | grep `/usr/lpp/mmfs/bin/mmlscluster | grep 'GPFS cluster name:' | awk '{print $4}' | awk -F '.' '{print $1}'` | awk  -F ' ' '{for(i=2;i<=NF;i++) print $i}'  > /tmp/gpfs_working/current-nodes"
  ignore_failure true
  action :run
end

execute "obtain_all_nsd_diskname_from_GPFS_cluster" do
  command "if [ -f /tmp/gpfs_working/nsd-disk.list ] ; then rm -rf /tmp/gpfs_working/nsd-disk.list ; fi ; /usr/lpp/mmfs/bin/mmlsnsd -L | grep #{node['gpfs']['gpfs_device_name']} | grep -v grep | awk '{print $2}' > /tmp/gpfs_working/nsd-disk.list "
  ignore_failure true
  action :run
end



execute "umount_GPFS_filesystem" do
  command "/usr/lpp/mmfs/bin/mmumount all -a"
  ignore_failure true
  action :run
end


##command "/usr/lpp/mmfs/bin/mmdelfs gpfs_dev"
execute "delfs_command" do
  command "/usr/lpp/mmfs/bin/mmdelfs #{node['gpfs']['gpfs_device_name']}"
  ignore_failure true
  action :run
end

### command "if [ -f /tmp/gpfs_working/nsd-disk.list ] ; then rm -rf /tmp/gpfs_working/nsd-disk.list ; fi ; grep 'nsd=' /tmp/gpfs_working/diskslist.txt | grep -v '#' | awk -F '=' '{print $2}' > /tmp/gpfs_working/nsd-disk.list ; /usr/lpp/mmfs/bin/mmdelnsd -F  /tmp/gpfs_working/nsd-disk.list "
execute "delnsd_command" do
  command " /usr/lpp/mmfs/bin/mmdelnsd -F  /tmp/gpfs_working/nsd-disk.list "
  ignore_failure true
  action :run
end

execute "shutdown_GPFS_cluster" do
  command "/usr/lpp/mmfs/bin/mmshutdown -a"
  ignore_failure true
  action :run
end

execute "delnode_command" do
  command "/usr/lpp/mmfs/bin/mmdelnode -a"
  ignore_failure true
  action :run
end

#execute "" do
#  command ""
#  ignore_failure true
#  action :run
#end
