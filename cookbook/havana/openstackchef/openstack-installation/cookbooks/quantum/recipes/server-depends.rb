#
# Cookbook Name:: quantum
# Recipe:: depends
#
# Copyright 2013, IBM
#
# All rights reserved - Do Not Redistribute
#

node['quantum_server']['depends'].each do |role|
    check_role_num(role, 1)
end
