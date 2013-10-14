#
# Cookbook Name:: upgrade
# Recipe:: upgrade-cinder-volume
# Author: Tao Tao (ttao@us.ibm.com)
#
# Demo OpenStack Cinder Volume upgrade 
#

include_recipe "backup::backup-cinder-volume"

include_recipe "up_uninstall::up_uninstall-cinder-volume"

include_recipe "install::install-cinder-volume"

include_recipe "restore::restore-cinder-volume"


