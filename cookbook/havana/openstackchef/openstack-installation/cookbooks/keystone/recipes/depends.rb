#
# Cookbook Name:: keystone
# Recipe:: depends
#
# Copyright 2013, IBM
#
# All rights reserved - Do Not Redistribute
#

node['keystone']['depends'].each do |role|
    check_role_num(role, 1)
end
