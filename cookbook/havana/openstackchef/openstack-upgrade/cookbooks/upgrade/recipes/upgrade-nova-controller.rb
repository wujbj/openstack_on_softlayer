#
# Cookbook Name:: upgrade
# Recipe:: upgrade-nova-controller
# Author: Tao Tao (ttao@us.ibm.com)
#
# Demo OpenStack Nova Controller Upgrade
#

include_recipe "backup::backup-nova-controller"

include_recipe "up_uninstall::up_uninstall-nova-controller"

include_recipe "install::install-nova-controller"

include_recipe "restore::restore-nova-controller"

