#
# Cookbook Name:: db2
# Recipe:: database
#
# Copyright 2013, IBM
#
# All rights reserved - Do Not Redistribute
#

db2_database "create database" do
    db_name     node['db2']['db_name']
    action :create
end
