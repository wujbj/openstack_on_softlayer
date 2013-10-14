#/******************************************************* {COPYRIGHT} ***
# * Licensed Materials - Property of IBM
# *
# * 5725-C88
# *
# * (C) Copyright IBM Corp. 2012, 2013 All Rights Reserved
# *
# * US Government Users Restricted Rights - Use, duplication or
# * disclosure restricted by GSA ADP Schedule Contract with
# * IBM Corp.
#******************************************************* {COPYRIGHT} ***/
#
# Cookbook Name:: uninstall
# Recipe:: uninstall-openstack
# Author: Bao Hua Dai (bhdai@cn.ibm.com)
# Function: Remove all additional OpenStack packages
#

# Remove all the additional openstack  packages
#
execute "yum_remove_all_additional_openstack_pkg" do
 command "yum list | grep openstack |grep -v grep| while read name ver inst; do sy=`echo $inst | awk '{printf(\"%s\",substr($0,1,1))}'`; if [ -z $sy ] ; then continue; fi; if [ $sy == \"@\" ] ; then yum remove $name -y; fi ; done"
 action :run
 ignore_failure true
end

execute "remove_all_additional_openstack_pkg" do
 command "bash /usr/bin/yum-extra.sh ; yum clean all"
 action :run
 ignore_failure true
end

execute "remove_libvirt" do
 command "rm -rf /etc/libvirt ; rm -rf /var/lib/libvirt ; rm -rf /var/lib/cinder ; rm -rf /var/lib/mysql ; rm -rf /var/log/nova ; rm -rf /var/log/glance ; rm -rf /var/log/keystone ; rm -rf /var/lib/qpid* ; rm -rf /var/lib/keystone ; rm -rf /var/lib/glance ; rm -rf /etc/keystone ; rm -rf /etc/qpid* ; rm -rf /etc/glance ; rm -rf /etc/nova ; rm -rf /etc/my.cnf ; rm -rf /etc/yum.repos.d/openstack*.repo "
 action :run
 ignore_failure true
end
