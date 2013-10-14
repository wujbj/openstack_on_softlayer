#
# Cookbook Name:: qpid
# Recipe:: single
#
# Copyright 2013, IBM
#
# All rights reserved - Do Not Redistribute
#

qpid_setup "setup qpid" do
  port    node['qpid']['broker']['port']
  auth    node['qpid']['broker']['auth']
  action :create
end
