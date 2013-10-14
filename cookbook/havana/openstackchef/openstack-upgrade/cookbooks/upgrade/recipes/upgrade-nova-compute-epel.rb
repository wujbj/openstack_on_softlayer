#
# Cookbook Name:: upgrade
# Recipe:: upgrade-nova-compute-epel
# Author: Tao Tao (ttao@us.ibm.com)
#
# Demo OpenStack Nova Compute Upgrade
#

include_recipe "backup::backup-nova-compute"

include_recipe "uninstall::uninstall-nova-compute"

#include_recipe "yum::rhel"
#include_recipe "yum::epel"

include_recipe "install::install-nova-compute"

include_recipe "restore::restore-nova-compute"

