#
# Cookbook Name:: qpid
# Recipe:: active
#
# Copyright 2013, IBM
#
# All rights reserved - Do Not Redistribute
#

qpid_ha_setup "setup qpid active" do
  port    node['qpid']['broker']['port']
  auth    node['qpid']['broker']['auth']

  ha_public_url   node['qpid']['ha']['vip']
  ha_brokers_url  node['qpid']['ha']['brokers_url']
  ha_replicate    node['qpid']['ha']['replicate']
  ha_mechanism    node['qpid']['ha']['mechanism']
  ha_username     node['qpid']['ha']['username']
  ha_password     node['qpid']['ha']['password']
  ha_backup_timeout node['qpid']['ha']['backup_timeout']

  action :create
end
