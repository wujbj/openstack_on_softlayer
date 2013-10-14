#
# Cookbook Name:: openstack-ha
# Recipe:: glance
#
# Copyright 2013, IBM.
#

if node['glance_ha']
    check_role_num('glance', 2)
else
    puts "========================="
    puts " You Glance is not HA"
    puts "========================="
    exit(1)
    check_role_num('glance', 1)
end
