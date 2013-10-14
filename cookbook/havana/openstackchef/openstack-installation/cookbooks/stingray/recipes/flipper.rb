#
# Cookbook Name:: stingray
# Recipe:: flipper
#
# Copyright 2013, IBM
#
# All rights reserved - Do Not Redistribute
#

stingray_flipper "#{node['stingray']['flipper']['name']}" do
    ipaddress node['stingray']['flipper']['ip']
    keeptogether node['stingray']['flipper']['keeptogether']
    machines node['stingray']['flipper']['machines']
    action :create
end
