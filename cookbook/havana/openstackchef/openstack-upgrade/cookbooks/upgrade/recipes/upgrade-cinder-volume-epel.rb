#
# Cookbook Name:: upgrade
# Recipe:: upgrade-cinder-volume-epel 
# Author: Tao Tao (ttao@us.ibm.com)
#
# Demo OpenStack Cinder Volume upgrade 
#

include_recipe "backup::backup-cinder-volume"

include_recipe "uninstall::uninstall-cinder-volume"

#include_recipe "yum::rhel"
#include_recipe "yum::epel"

include_recipe "install::install-cinder-volume"

include_recipe "restore::restore-cinder-volume"


