#
# Cookbook Name:: openstack-ha
# Recipe:: nova-api-depends
#
# Copyright 2013, IBM.
#

if node['nova_api_ha']
    check_role_num('nova-api', 2)
else
    puts "========================="
    puts " You NOVA API is not HA"
    puts "========================="
    check_role_num('nova-api', 1)
end
