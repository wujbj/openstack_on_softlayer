#
# Cookbook Name:: uninstall
# Recipe:: uninstall-glance
# Author: Bao Hua Dai (bhdai@cn.ibm.com)
# Function: Remove OpenStack glance packages
#

# Stop keystone service
service "openstack-glance-api" do
    action :stop
end
service "openstack-glance-registry" do
    action :stop
end

#service "openstack-" do
#    action :stop
#end

#
# Remove the openstack glance packages
#
execute "yum_remove_glance" do
 command "yum remove -y openstack-glance"
 action :run
end

#
# Remove the openstack python-glance package
#
execute "yum_remove_python_glance" do
 command "yum remove -y python-glance* ; yum -y remove python-nova* ; yum -y remove python-swift* ; yum -y remove python-keystone* ; yum -y remove python-glance* ; yum -y remove python-quantum* ; yum -y remove python-cinder*"
 action :run
end

execute "delete_keystone_repo" do
 command "rm -rf /etc/glance ; rm -rf /var/log/glance ; rm -rf /var/lib/glance"
 action :run
end
