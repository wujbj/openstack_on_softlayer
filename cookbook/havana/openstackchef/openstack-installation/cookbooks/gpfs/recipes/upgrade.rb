#
# Cookbook Name:: gpfs
# Recipe:: upgrade
#
# Upgrade GPFS cluster.
# 
# Run this cookbook on every node in GPFS cluster
#
### Bao Hua Dai comment this function on Aug. 14th, 2013
#execute "obtain_GPFS_upgrade_packages" do
#  command "if [ ! -d /tmp/gpfs_upgrade ] ; then  mkdir -p /tmp/gpfs_upgrade ; else rm -rf /tmp/gpfs_upgrade ; mkdir -p /tmp/gpfs_upgrade ; fi ; address=`echo \"#{node['gpfs']['upgrade_rpms']}\" | awk -F ':' '{printf(\"%s\\n\",substr($2,3,length($2)-2))}'` ; directory=`echo \"#{node['gpfs']['upgrade_rpms']}\" | awk -F ':' '{printf(\"%s\\n\",substr($3,6,length($3)-5))}'` ; scp -r $address:/var/www/html/$directory  /tmp/gpfs_upgrade/. ; cd /tmp/gpfs_upgrade/$directory ; ls *.rpm | while read name;  do rpm -U $name ; done ; cd - "
#  ignore_failure true
#  action :run
#end


### Bao Hua Dai add this on Aug. 14th, 2013
puts "node['gpfs']['upgrade_rpms'] #{node['gpfs']['upgrade_rpms']}"
execute "judge-tmp-gpfs_upgrade_directory" do
  command "if [ ! -d /tmp/gpfs_upgrade ] ; then  mkdir -p /tmp/gpfs_upgrade ; else rm -rf /tmp/gpfs_upgrade ; mkdir -p /tmp/gpfs_upgrade ; fi"
  ignore_failure true
  action :run
end

execute "obtain_and_apply_GPFS_upgrade_packages" do
  cwd "/tmp/gpfs_upgrade"
  command " wget -r -np -nd --accept=.rpm --reject=.html #{node['gpfs']['upgrade_rpms']} ;  ls *.rpm | while read name;  do rpm -U $name ; done"
  ignore_failure true
  action :run
  not_if { node['gpfs']['upgrade_rpms'].empty? }
end
#not_if { node['gpfs']['upgrade_rpms'].nil? }

#execute "do_upgrade_GPFS_packages" do
#  command "cd /tmp/gpfs_upgrade ; ls *.rpm | while read name;  do rpm -U $name ; done ; cd - "
#  ignore_failure true
#  action :run
#end

execute "recompile_and_reapply_GPFS" do
  command "cd /usr/lpp/mmfs/src ; export SHARKCLONEROOT=/usr/lpp/mmfs/src ; make Autoconfig ; make World ; make InstallImages ; cd -"
  ignore_failure true
  action :run
end

#execute "" do
#  command ""
#  ignore_failure true
#  action :run
#end
