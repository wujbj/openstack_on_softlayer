#
# Cookbook Name:: openstack-ha
# Recipe:: ec2-api-depends
#
# Copyright 2013, IBM.
#

if node['ec2_api_ha']
    check_role_num('ec2-api', 2)
else
    puts "========================="
    puts " You ec2 api is not HA"
    puts "========================="
    exit(1)
    check_role_num('ec2-api', 1)
end
