#
# Cookbook Name:: openstack-network
# Recipe:: setup
#

include_recipe "openstack-common::rcfile"

cidr = node['openstack']['network']['networks'].first['ipv4_cidr']
if cidr.nil?
    cidr = "10.5.5.0/24"
end

network_type = node['openstack']['network']['openvswitch']['tenant_network_type']
if network_type == 'gre'
  bash "create neutron gre network" do
    code <<-EOH
    source /root/keystonerc
    if ! neutron net-show net1; then
      net1=$(neutron net-create net1 | awk '/ id /{print $4}')
    fi
    if ! neutron subnet-show subnet1;  then
      subnet1=$(neutron subnet-create --name=subnet1 net1 #{cidr} | awk '/ id /{print $4}')
    fi
    if ! neutron router-show router1; then
      router1=$(neutron router-create router1 | awk '/ id /{print $4}')
      neutron router-interface-add $router1 $subnet1
    fi
    EOH
  end
elsif network_type == 'vlan'
  bash "create neutron vlan network" do
    code <<-EOH
    source /root/keystonerc
    if ! neutron net-show net1; then
      net1=$(neutron net-create net1 | awk '/ id /{print $4}')
    fi
    if ! neutron subnet-show subnet1;  then
      subnet1=$(neutron subnet-create --name=subnet1 net1 #{cidr} | awk '/ id /{print $4}')
    fi
    EOH
  end
else
  puts '========================================='
  puts "unsupported network type(#{network_type})"
  puts '========================================='
end
