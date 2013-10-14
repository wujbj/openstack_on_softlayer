#
# Cookbook Name:: upgrade
# Recipe:: upgrade-nova-controller-epel
# Author: Tao Tao (ttao@us.ibm.com)
#
# Demo OpenStack Nova Controller Upgrade
#

include_recipe "backup::backup-nova-controller"

include_recipe "uninstall::uninstall-nova-controller"

#include_recipe "yum::rhel"
#include_recipe "yum::epel"

include_recipe "install::install-nova-controller"

include_recipe "restore::restore-nova-controller"

