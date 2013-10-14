#
# Cookbook Name:: openstack-network
# Recipe:: opensvswitch
#
# Copyright 2013, AT&T
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

require 'uri'

class ::Chef::Recipe
  include ::Openstack
end

include_recipe "openstack-network-havana::common"

platform_options = node["openstack"]["network"]["platform"]
driver_name = node["openstack"]["network"]["interface_driver"].split('.').last.downcase
main_plugin = node["openstack"]["network"]["interface_driver_map"][driver_name]
core_plugin = node["openstack"]["network"]["core_plugin"]
network_type = node["openstack"]["network"]["openvswitch"]["tenant_network_type"]

if platform?("ubuntu", "debian")

  # obtain kernel version for kernel header
  # installation on ubuntu and debian
  kernel_ver = node["kernel"]["release"]
  package "linux-headers-#{kernel_ver}" do
    options platform_options["package_overrides"]
    action :install
  end

end

platform_options["neutron_openvswitch_packages"].each do |pkg|
  package pkg do
    action :install
  end
end

service "neutron-openvswitch-switch" do
  service_name platform_options["neutron_openvswitch_service"]
  supports :status => true, :restart => true
  action [:enable, :start]
end

#service "neutron-server" do
#  service_name platform_options["neutron_server_service"]
#  supports :status => true, :restart => true
#  ignore_failure true
#  action :nothing
#end

platform_options["neutron_openvswitch_agent_packages"].each do |pkg|
  package pkg do
    action :install
    options platform_options["package_overrides"]
  end
end

service "neutron-plugin-openvswitch-agent" do
  service_name platform_options["neutron_openvswitch_agent_service"]
  supports :status => true, :restart => true
  action :enable
end

execute "neutron-node-setup --plugin openvswitch" do
  only_if { platform?(%w(fedora redhat centos)) } # :pragma-foodcritic: ~FC024 - won't fix this
end

if not ["nicira", "plumgrid", "bigswitch"].include?(main_plugin)
  int_bridge = node["openstack"]["network"]["openvswitch"]["integration_bridge"]
  execute "create internal network bridge" do
    ignore_failure true
    command "ovs-vsctl add-br #{int_bridge}"
    action :run
    not_if "ovs-vsctl show | grep 'Bridge #{int_bridge}'"
    notifies :restart, "service[neutron-plugin-openvswitch-agent]", :delayed
  end
end

if not ["nicira", "plumgrid", "bigswitch"].include?(main_plugin)
  case network_type
  when "gre"
    tun_bridge = node["openstack"]["network"]["openvswitch"]["tunnel_bridge"]
    execute "create tunnel network bridge" do
      ignore_failure true
      command "ovs-vsctl add-br #{tun_bridge}"
      action :run
      not_if "ovs-vsctl show | grep 'Bridge #{tun_bridge}'"
      notifies :restart, "service[neutron-plugin-openvswitch-agent]", :delayed
    end
  when "vlan"
     phy_iface = node["openstack"]["network"]["openvswitch"]["physical_network_interface"]
     execute "create physical network bridge" do
       ignore_failure true
       command "ovs-vsctl add-br br-#{phy_iface} && ovs-vsctl add-port br-#{phy_iface} #{phy_iface}"
       action :run
       not_if "ovs-vsctl show | grep 'Bridge br-#{phy_iface}'"
       notifies :restart, "service[neutron-plugin-openvswitch-agent]", :delayed
     end
  end
end

if node['openstack']['network']['disable_offload']

  package "ethtool" do
    action :install
    options platform_options["package_overrides"]
  end

  service "disable-eth-offload" do
    supports :restart => false, :start => true, :stop => false, :reload => false
    priority({ 2 => [ :start, 19 ]})
    action :nothing
  end

  # a priority of 19 ensures we start before openvswitch
  # at least on ubuntu and debian
  cookbook_file "disable-eth-offload-script" do
    path "/etc/init.d/disable-eth-offload"
    source "disable-eth-offload.sh"
    owner "root"
    group "root"
    mode "0755"
    notifies :enable, "service[disable-eth-offload]"
    notifies :start, "service[disable-eth-offload]"
  end
end
