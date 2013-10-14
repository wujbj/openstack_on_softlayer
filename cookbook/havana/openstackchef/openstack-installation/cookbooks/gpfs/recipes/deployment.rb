#
# Cookbook Name:: gpfs
# Recipe:: deployment
#
# Configure and start GPFS cluster.
# 

execute "create_GPFS_cluster" do
  command "source $HOME/.bash_profile ; master=`awk -F ',' '{print $1}' /tmp/gpfs_working/master-second` ; second=`awk -F ',' '{print $2}' /tmp/gpfs_working/master-second` ;echo $master ; echo $second; if [ $master == $second ] ; then /usr/lpp/mmfs/bin/mmcrcluster -N /tmp/gpfs_working/nodeslist.txt -p $master -r /usr/bin/ssh -R /usr/bin/scp -C #{node['gpfs']['cluster_name']}; else /usr/lpp/mmfs/bin/mmcrcluster -N /tmp/gpfs_working/nodeslist.txt -p $master -s $second -r /usr/bin/ssh -R /usr/bin/scp -C #{node['gpfs']['cluster_name']}; fi "
  # ignore/sleep commented out
  #ignore_failure true
  action :run
end

execute "sleep_25_seconds" do
  # ignore/sleep commented out
  command "sleep 25"
  #ignore_failure true
  action :run
end

execute "apply_GPFS_license" do
  command "source $HOME/.bash_profile ; /usr/lpp/mmfs/bin/mmchlicense server --accept -N all"
  # ignore/sleep commented out
  #ignore_failure true
  action :run
end

execute "sleep_15_seconds" do
  # ignore/sleep commented out
  command "sleep 15"
  #ignore_failure true
  action :run
end

execute "create_GPFS_NSD_device" do
  command "source $HOME/.bash_profile ; /usr/lpp/mmfs/bin/mmcrnsd -F /tmp/gpfs_working/diskslist.txt -v no"
  # ignore/sleep commented out
  #ignore_failure true
  action :run
end

execute "sleep_10_seconds" do
  # ignore/sleep commented out
  command "sleep 10"
  #ignore_failure true
  action :run
end

execute "start_GPFS_cluster" do
  command "source $HOME/.bash_profile ; /usr/lpp/mmfs/bin/mmstartup -a "
  # ignore/sleep commented out
  #ignore_failure true
  action :run
end

execute "sleep_40_seconds" do
  # ignore/sleep commented out
  puts "Sleeping for 40 secs for gpfs cluster to start"
  command "sleep 40"
  #ignore_failure true
  action :run
end

#command "source $HOME/.bash_profile ; nodes_number=`grep -v \"^#\" /tmp/gpfs_working/nodeslist.txt | grep -v \"^$\" | wc -l` ;active_nodes=`/usr/lpp/mmfs/bin/mmgetstate -a | grep active | wc -l` ; if [ $nodes_number -eq $active_nodes ] ; then /usr/lpp/mmfs/bin/mmcrfs #{node['gpfs']['gpfs_device_name']} -F /tmp/gpfs_working/diskslist.txt -A yes -B #{node['gpfs']['block_size']} -m #{node['gpfs']['default_metadata_replicas']} -M #{node['gpfs']['max_metadata_replicas']} -r #{node['gpfs']['default_data_replicas']} -R #{node['gpfs']['max_data_replicas']}  -k all -Q yes -v no --write-affinity-depth #{node['gpfs']['writeAffinityDepth']} ; fi "
####=>denish's command :  mmcrfs -T /gpfs devr1n2fs -F diskfile -A yes -m 2 -M 2 -n 32 -Q no -j cluster -r 1 -R 2 -B 1M -L 512M -v no --write-affinity-depth 1
#### mmcrfs gpfs_dev -F /tmp/gpfs_working/diskslist.txt -A yes -B 512K -m 1 -M 2 -r 1 -R 2  -k all -Q yes -v no --write-affinity-depth 1 
execute "create_GPFS_filesystem" do
  command "source $HOME/.bash_profile ; nodes_number=`grep -v \"^#\" /tmp/gpfs_working/nodeslist.txt | grep -v \"^$\" | wc -l` ;active_nodes=`/usr/lpp/mmfs/bin/mmgetstate -a | grep active | wc -l` ; if [ $nodes_number -eq $active_nodes ] ; then /usr/lpp/mmfs/bin/mmcrfs #{node['gpfs']['gpfs_device_name']} -F /tmp/gpfs_working/diskslist.txt -A yes -B #{node['gpfs']['block_size']} -m #{node['gpfs']['default_metadata_replicas']} -M #{node['gpfs']['max_metadata_replicas']} -n #{node['gpfs']['numNodes']}  -Q no -j #{node['gpfs']['layoutMap']} -r #{node['gpfs']['default_data_replicas']} -R #{node['gpfs']['max_data_replicas']} -L #{node['gpfs']['logfilesize']} -v no --write-affinity-depth #{node['gpfs']['writeAffinityDepth']}; fi "
  ignore_failure true
  action :run
  retries 5
  retry_delay 30
end

execute "sleep_25_seconds" do
  # ignore/sleep commented out
  command "sleep 25"
  ignore_failure true
  action :run
end

execute "mount_GPFS_filesystem" do
  command "source $HOME/.bash_profile ; /usr/lpp/mmfs/bin/mmmount all -a"
  # ignore/sleep commented out
  #ignore_failure true
  action :run
end

execute "sleep_35_seconds" do
  # ignore/sleep commented out
  command "sleep 35"
  ignore_failure true
  action :run
end

execute "change_policy" do
  command "cd /tmp/gpfs_working ; /usr/lpp/mmfs/bin/mmchpolicy #{node['gpfs']['gpfs_device_name']} /tmp/gpfs_working/policy-definition ; cd - "
  # ignore/sleep commented out
  #ignore_failure true
  action :run
end

execute "sleep_15_seconds" do
  # ignore/sleep commented out
  command "sleep 15"
  ignore_failure true
  action :run
end

execute "add_autoload_attribute_to_GPFS_cluster" do
  cwd "/tmp/gpfs_working"
  command "/usr/lpp/mmfs/bin/mmchconfig autoload=yes"
  # ignore/sleep commented out
  #ignore_failure true
  action :run
end

execute "sleep_25_seconds" do
  # ignore/sleep commented out
  command "sleep 25"
  ignore_failure true
  action :run
end

#execute "add_gpfs_service" do
#  command "ln -s /usr/lpp/mmfs/bin/gpfsrunlevel /etc/init.d/gpfs"
#  ignore_failure true
#  action :run
#  not_if { test -f "/etc/init.d/gpfs" }
#done

#execute "configure_gpfs_service" do
#  command "chkconfig --level 345 gpfs on "
#  ignore_failure true
#  action :run
#  only_if { test -f "/etc/init.d/gpfs" }
#done

#execute "" do
#  command ""
#  ignore_failure true
#  action :run
#end
