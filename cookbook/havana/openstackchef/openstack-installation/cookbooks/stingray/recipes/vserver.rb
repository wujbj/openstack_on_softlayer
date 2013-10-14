#
# Cookbook Name:: stingray
# Recipe:: vserver
#
# Copyright 2013, IBM
#
# All rights reserved - Do Not Redistribute
#

stingray_vserver "#{node['stingray']['vserver']['name']}" do
    port node['stingray']['vserver']['port']
    pool node['stingray']['vserver']['pool']
    action :create
end
