#
# Cookbook Name:: stingray
# Recipe:: pool
#
# Copyright 2013, IBM
#
# All rights reserved - Do Not Redistribute
#

stingray_pool "#{node['stingray']['pool']['name']}" do
    monitors node['stingray']['pool']['monitors']
    algorithm node['stingray']['pool']['algorithm']
    nodes node['stingray']['pool']['nodes']
    action :create
end
