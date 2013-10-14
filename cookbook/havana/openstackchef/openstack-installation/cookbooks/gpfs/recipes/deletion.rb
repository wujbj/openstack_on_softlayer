
# Cookbook Name:: gpfs
# Recipe:: deletion
#
# Erase gpfs cluster and mount point.
# Need to run on every GPFS cluster node.

#execute "erase_mount_point" do
#  command "umount /dev/gpfs_dev ; umount /dev/gpfs_dev ; /usr/lpp/mmfs/bin/mmshutdown -a ; rm -rf /gpfs"
#  ignore_failure true
#  action :run
#end

#execute "erase_var_mmfs_gen" do
#  command "/usr/lpp/mmfs/bin/mmdelfs #{node['gpfs']['gpfs_device_name']} ; rm -rf /var/mmfs/gen ; rm -rf /gpfs"
#  ignore_failure true
#  action :run
#end

execute "erase_var_adm_ras" do
  command " if [ -d /var/adm/ras ] ; then rm -rf /var/adm/ras/* ; fi" 
  ignore_failure true
  action :run
end

execute "erase_all_gpfs_packages" do
  command "yum -y erase gpfs.base.x86_64 ; yum -y erase gpfs.docs.noarch ; yum -y erase gpfs.gpl.noarch ; yum -y erase gpfs.libsrc.noarch ; yum -y erase gpfs.msg.en_US.noarch ; yum -y erase gpfs.src.noarch ; rm -rf /usr/lpp/mmfs ; rm -rf /var/mmfs"
  ignore_failure true
  action :run
end

execute "erase_gpfs_repo" do
  command "rm -rf /etc/yum.repos.d/gpfs.repo"
  ignore_failure true
  action :run
end
