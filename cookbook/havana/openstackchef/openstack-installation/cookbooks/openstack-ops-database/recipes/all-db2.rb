#
# Cookbook Name:: openstack-db
# Recipe:: all-db2
#
# Copyright 2013, IBM
#
# All rights reserved - Do Not Redistribute
#

db_name = node['openstack']['db']['db2_name']

db2_database "create OpenStack database(#{db_name})" do
    db_name db_name
    action :create
end
