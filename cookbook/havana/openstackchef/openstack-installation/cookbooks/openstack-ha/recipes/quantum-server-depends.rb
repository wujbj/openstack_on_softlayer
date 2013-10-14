#
# Cookbook Name:: openstack-ha
# Recipe:: quantum-depends
#
# Copyright 2013, IBM.
#

if node['quantum_server_ha']
    check_role_num('quantum-server', 2)
else
    puts "========================="
    puts " You Qauntum Server is not HA"
    puts "========================="
    exit(1)
    check_role_num('quantum-server', 1)
end
