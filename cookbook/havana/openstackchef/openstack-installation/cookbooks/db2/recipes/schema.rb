#
# Cookbook Name:: db2
# Recipe:: schema
#
# Copyright 2013, IBM
#
# All rights reserved - Do Not Redistribute
#

## This recipe is used for creating SCHEMA by using DB2 native client.
## Please use DB2 ODBC Driver to create it if you can.

## You must create database and user before create schema

db_user = node['db2']['db_user']
db_name = node['db2']['db_name']
schema_name = node['db2']['db_schema']
instance_username = node['db2']['instance_username']

#===================================================

execute "create database schema" do
    command "su - #{instance_username} -c '(db2 connect to #{db_name}) && (db2 CREATE SCHEMA #{schema_name} AUTHORIZATION #{db_user}) && (db2 connect reset)'"
end
