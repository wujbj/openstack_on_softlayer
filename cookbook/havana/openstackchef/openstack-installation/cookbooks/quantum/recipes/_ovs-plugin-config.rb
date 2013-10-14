#
# Cookbook Name:: quantum
# Recipe:: _ovs-plugin-config
#
# Copyright 2012, Rackspace US, Inc.
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

class ::Chef::Recipe
    include ::Openstack
end


# Set OVS specific attribute
node.default[:quantum][:interface_driver] = "quantum.agent.linux.interface.OVSInterfaceDriver"

if node["openstack"]["db"]["service_type"] == "mysql"
  mysql_info = get_access_endpoint("os-ops-database", "mysql", "db")
elsif node["openstack"]["db"]["service_type"] == "db2"
  include_recipe "db2::odbc_install"
end

local_ip = get_ip_for_net("nova")
if local_ip.nil?
    local_ip = node["ipaddress"]
end

db_user = node["openstack"]["network"]["db"]["username"]
db_pass = db_password "quantum"
db_connection = db_uri("network", db_user, db_pass)

#db_connection = get_db_connection(node["openstack"]["db"]["service_type"], node["quantum"]["db"]["name"], node["quantum"]["db"]["username"], node["quantum"]["db"]["password"])

template "/etc/quantum/plugins/openvswitch/ovs_quantum_plugin.ini" do
        source "ovs_quantum_plugin.ini.erb"
        owner "quantum"
        group "quantum"
        mode "0644"
        variables(
#                "db_user" => node['quantum']['db']['username'],
#                "db_password" => node['quantum']['db']['password'],
#                "db_ip_address" => mysql_info['host'], 
#                "db_name" => node['quantum']['db']['name'],
		"db_connection" => db_connection,
                "tenant_network_type" => node['quantum']['openvswitch']['tenant_network_type'],
                "enable_tunneling" => node['quantum']['openvswitch']['enable_tunneling'],
                "tunnel_id_range" => node['quantum']['openvswitch']['tunnel_id_range'],
                "network_vlan_range" => "#{node['quantum']['openvswitch']['physical_device_reference']}#{node['quantum']['openvswitch']['network_vlan_range']}",
                "network_vm_bridge" => node['quantum']['openvswitch']['vm_bridge'],
		"bridge_mappings" => "#{node['quantum']['openvswitch']['physical_device_reference']}#{node['quantum']['openvswitch']['vm_bridge']}",
		"local_ip" => local_ip
        )

	only_if do
		node['roles'].include?("quantum-server") or
		node['roles'].include?("quantum-ovs-agent")	
	end
end

service "quantum-server" do
	action :restart
	only_if { node['roles'].include?("quantum-server") } 
end

service "openvswitch" do
	action :restart
	only_if { node['roles'].include?("quantum-ovs-agent") }
end
