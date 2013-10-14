#
# Cookbook Name:: openstack-ha
# Recipe:: keystone-depends
#
# Copyright 2013, IBM.
#

if node['keystone_ha']
    check_role_num('keystone', 2)
else
    puts "========================="
    puts " You Keystone is not HA"
    puts "========================="
    exit(1)
end
