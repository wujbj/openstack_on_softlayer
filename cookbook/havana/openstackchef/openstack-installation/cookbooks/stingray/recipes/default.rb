#
# Cookbook Name:: stingray
# Recipe:: default
#
# Copyright 2013, IBM
#
# All rights reserved - Do Not Redistribute
#

#stingray "stingray" do
#    url "http://172.16.1.24/stingray.tar.gz"
#    action :install
#end

#stingray_init_cluster "cluster" do
#    license_key ''
#    password 'passw0rd'
#end

#stingray_join_cluster "join_cluster" do
#    cluster_host '172.16.1.26'
#    password 'passw0rd'
#end

#stingray_flipper "default-flipper" do
#    ipaddress "172.16.1.253"
#    keeptogether 'No'
#    machines ['devr1n25.c2sdev.democentral.ibm.com.', 'devr1n26.c2sdev.democentral.ibm.com.']
#    action :create
#end
#
#stingray_pool "default-pool" do
#    monitors "Simple HTTP"
#    algorithm "roundrobin"
#    nodes ['172.16.0.1:80', '172.16.1.24:80']
#    action :create
#end
#
#stingray_vserver "default-vserver" do
#    port 8080
#    pool 'default-pool'
#    action :create
#end
