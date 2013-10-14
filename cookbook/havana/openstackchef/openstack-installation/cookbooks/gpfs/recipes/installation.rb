#
# Cookbook Name:: gpfs
# Recipe:: installation
#
# Install gpfs packages and driver layer
# Need to run on every GPFS cluster node.

execute "installing_the_packages_which_gpfs_depend_on_therm" do
  command "yum clean all ; yum -y install libstdc++.x86_64 ; yum -y install compat-libstdc++-296.i686 ; yum -y install compat-libstdc++-33.x86_64 ; yum -y install libXp.x86_64 ; yum -y install imake.x86_64 ; yum -y install gcc-c++.x86_64 ; yum -y install kernel.x86_64 ; yum -y install kernel-headers.x86_64 ; yum -y install kernel-devel.x86_64 ; yum -y install xorg-x11-xauth.x86_64 ; yum -y install ksh.x86_64 ; yum -y install make.x86_64"
  #ignore_failure true
  action :run
end

execute "installing_gpfs_self_packages" do
  # temp commented out to install 3.5.0-7 version instead of 10 for testing
  #command "yum clean all ; yum -y install gpfs.base.x86_64 ; yum -y install gpfs.gpl.noarch ; yum -y install gpfs.msg.en_US.noarch ; yum -y install gpfs.docs.noarch"
  command "yum clean all ; yum -y install gpfs.base-3.5.0-7.x86_64 ; yum -y install gpfs.gpl.noarch ; yum -y install gpfs.msg.en_US.noarch ; yum -y install gpfs.docs.noarch"
  
  #ignore_failure true
  action :run
end

##command "yum clean all ;yum -y install gpfs.src.noarch ; yum -y install gpfs.libsrc.noarch ; cd /usr/lpp/mmfs/src ; export SHARKCLONEROOT=/usr/lpp/mmfs/src ; make Autoconfig ; make World ; make InstallImages; echo \"export PATH=\$PATH:/usr/lpp/mmfs/bin\" >>$HOME/.bash_profile ; source $HOME/.bash_profile "
execute "installing_gpfs_drivers" do
  command "yum clean all ;yum -y install gpfs.src.noarch ; yum -y install gpfs.libsrc.noarch " 
  #ignore_failure true
  action :run
end

### good work
#execute "obtain_GPFS_upgrade_packages" do
#  command "if [ ! -z \"#{node['gpfs']['upgrade_rpms']}\" ] ; then  if [ ! -d /tmp/gpfs_upgrade ] ; then  mkdir -p /tmp/gpfs_upgrade ; else rm -rf /tmp/gpfs_upgrade ; mkdir -p /tmp/gpfs_upgrade ; fi ; address=`echo \"#{node['gpfs']['upgrade_rpms']}\" | awk -F ':' '{printf(\"%s\\n\",substr($2,3,length($2)-2))}'` ; directory=`echo \"#{node['gpfs']['upgrade_rpms']}\" | awk -F ':' '{printf(\"%s\\n\",substr($3,6,length($3)-5))}'` ; scp -r $address:/var/www/html/$directory  /tmp/gpfs_upgrade/. ; cd /tmp/gpfs_upgrade/$directory ; ls *.rpm | while read name;  do rpm -U $name ; done ; cd - ; fi "
#  ignore_failure true
#  action :run
#end

### Bao Hua Dai add this on Aug. 14th, 2013
execute "obtain_and_apply_GPFS_upgrade_packages" do
  command "if [ ! -d /tmp/gpfs_upgrade ] ; then  mkdir -p /tmp/gpfs_upgrade ; else rm -rf /tmp/gpfs_upgrade ; mkdir -p /tmp/gpfs_upgrade ; fi ; cd /tmp/gpfs_upgrade ; wget -r -np -nd --accept=.rpm --reject=.html #{node['gpfs']['upgrade_rpms']} ;  ls *.rpm | while read name;  do rpm -U $name ; done"
  #ignore_failure true
  action :run
  not_if { node['gpfs']['upgrade_rpms'].empty? }
end
#not_if { node['gpfs']['upgrade_rpms'].nil? }

#execute "do_upgrade_GPFS_packages" do
#  command "if [ ! -z #{node['gpfs']['upgrade_rpms']} ] ; then cd /tmp/gfsp_upgrade ; ls *.rpm | while read name;  do rpm -U $name ; done ; cd - ; fi "
#  ignore_failure true
#  action :run
#end

execute "compile_and_install_gpfs_drivers" do
  command "cd /usr/lpp/mmfs/src ; export SHARKCLONEROOT=/usr/lpp/mmfs/src ; make Autoconfig ; make World ; make InstallImages; echo \"export PATH=\$PATH:/usr/lpp/mmfs/bin\" >>$HOME/.bash_profile ; source $HOME/.bash_profile "
  #ignore_failure true
  action :run
end

execute "create_gpfs_working_directory" do
  command " if [ ! -d /tmp/gpfs_working ] ; then  mkdir -p /tmp/gpfs_working ; else rm -rf /tmp/gpfs_working ; mkdir -p /tmp/gpfs_working ; fi  "
  ignore_failure true
  action :run
end

#execute "obtain_disks_info_from_every_node" do
#  command "node=`hostname` ; if [ -f /tmp/gpfs_working/$node.disk-info ] ; then rm -rf /tmp/gpfs_working/$node.disk-info ; fi ; parted -l | grep logical | grep -v grep | awk '{if($1 != \"Sector\") printf(\"%s\\n\",$1)}'  | while read a ; do echo \"${node}  /dev/sda${a}\" >> /tmp/gpfs_working/$node.disk-info; done ; if [ $node != \"#{node['gpfs']['master_node']}\" ] ; then scp /tmp/gpfs_working/$node.disk-info #{node['gpfs']['master_node']}:/tmp/gpfs_working/. ; fi "
#  ignore_failure true
#  action :run
#end

#execute "generate_nodes_file_on_every_node" do
#  command " node=`hostname` ; echo \"${node}\" > /tmp/gpfs_working/$node.nodes-file ; if [ $node != \"#{node['gpfs']['master_node']}\" ] ; then scp /tmp/gpfs_working/$node.nodes-file #{node['gpfs']['master_node']}:/tmp/gpfs_working/. ; fi "
#  ignore_failure true
#  action :run
#end

