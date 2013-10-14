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
  bash "create quantum gre network" do
    code <<-EOH
    source /root/keystonerc
    if ! quantum net-show net1; then
      net1=$(quantum net-create net1 | awk '/ id /{print $4}')
    fi
    if ! quantum subnet-show subnet1;  then
      subnet1=$(quantum subnet-create --name=subnet1 net1 #{cidr} | awk '/ id /{print $4}')
    fi
    if ! quantum router-show router1; then
      router1=$(quantum router-create router1 | awk '/ id /{print $4}')
      quantum router-interface-add $router1 $subnet1
    fi
    EOH
  end
elsif network_type == 'vlan'
  bash "create quantum vlan network" do
    code <<-EOH
    source /root/keystonerc
    if ! quantum net-show net1; then
      net1=$(quantum net-create net1 | awk '/ id /{print $4}')
    fi
    if ! quantum subnet-show subnet1;  then
      subnet1=$(quantum subnet-create --name=subnet1 net1 #{cidr} | awk '/ id /{print $4}')
    fi
    EOH
  end
else
  puts '========================================='
  puts "unsupported network type(#{network_type})"
  puts '========================================='
end
