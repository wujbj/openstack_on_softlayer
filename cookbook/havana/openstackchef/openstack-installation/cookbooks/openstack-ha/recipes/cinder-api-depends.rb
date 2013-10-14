#
# Cookbook Name:: openstack-ha
# Recipe:: cinder-depends
#
# Copyright 2013, IBM.
#

if node['cinder_api_ha']
    check_role_num('cinder-api', 2)
else
    puts "========================="
    puts "You Cinder API is not HA"
    puts "========================="
    exit(1)
    check_role_num('cinder-api', 1)
end
