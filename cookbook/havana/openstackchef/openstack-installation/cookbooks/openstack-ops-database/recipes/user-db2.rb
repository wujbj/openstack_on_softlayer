#
# Cookbook Name:: openstack-db
# Recipe:: user-db2
#
# Copyright 2013, IBM
#
# All rights reserved - Do Not Redistribute
#

db_name = node['openstack']['db']['db2_name']

services = node['openstack']['services']

services.each do |service|
   service_specific=node["openstack"]["servicehash"]["#{service}"]

   ret = db_password service_specific

   if not ret.nil?
     password = ret 
   else
     password = node[service]["db"]["password"]
   end 

   root_pass = node['mysql']['server_root_password']
   #db_name = node[service]["db"]["name"]
   #db_name = node["openstack"]["db"][service]["db_name"]
   db_user = node["openstack"]["#{service}"]["db"]["username"]

   db2_user "create database(#{db_name}) user(#{db_user})" do
        db_name db_name
        db_user db_user
        db_pass password
        action :create
   end
end
