#
# Cookbook Name:: openstack-block-storage-ibm
# Recipe:: default
#
# Copyright 2013, IBM Corporation
#
# All rights reserved - Do Not Redistribute
#

# Open iptables port for keystone if set
if node["iptables"]["enabled"] == true
  include_recipe "openstack-block-storage-ibm::iptables"
end

# Call the patch recipe
include_recipe "openstack-block-storage-ibm::patch"

# Call pacemaker for monitor recipe to configure HA for keystone
if node["ha"]["pacemaker"]
  include_recipe "openstack-block-storage-ibm::pacemaker"
else
  include_recipe "openstack-block-storage-ibm::monitor"
end

