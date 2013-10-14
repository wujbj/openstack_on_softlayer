#
# Cookbook Name:: nova
# Recipe:: api-depends
#
# Copyright 2013, IBM
#
# All rights reserved - Do Not Redistribute
#

node['nova_scheduler']['depends'].each do |role|
    check_role_num(role, 1)
end