#
# Cookbook Name:: upgrade
# Recipe:: upgrade-nova-compute
# Author: Tao Tao (ttao@us.ibm.com)
#
# Demo OpenStack Nova Compute Upgrade
#

include_recipe "backup::backup-nova-compute"

include_recipe "up_uninstall::up_uninstall-nova-compute"

include_recipe "install::install-nova-compute"

include_recipe "restore::restore-nova-compute"

