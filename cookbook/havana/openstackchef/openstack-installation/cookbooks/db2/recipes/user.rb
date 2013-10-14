#
# Cookbook Name:: db2
# Recipe:: user
#
# Copyright 2013, IBM
#
# All rights reserved - Do Not Redistribute
#

db2_user "create database user" do
    db_user     node['db2']['db_user']
    db_pass     node['db2']['db_pass']
    db_name     node['db2']['db_name']
    # privileges  'CONNECT,DATAACCESS'
    action :create
end
