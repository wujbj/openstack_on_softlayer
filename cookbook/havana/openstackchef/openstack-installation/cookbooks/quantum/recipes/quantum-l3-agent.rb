#
# Cookbook Name:: quantum
# Recipe:: quantum-l3-agent
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

# install services
platform_options = node['quantum']['platform']

platform_options['quantum_l3_agent_packages'].each do |pkg|
  package pkg do
    action :upgrade
    retries 5
    retry_delay 10
    options platform_options['package_overrides']
  end
end

platform_options['quantum_l3_agent_services'].each do |svc|
  service svc do
    service_name svc
    supports :status => true, :restart => true
    action :enable
    subscribes :restart, "template[/etc/quantum/quantum.conf]", :delayed
    subscribes :restart, "template[/etc/quantum/l3-agent.ini]", :delayed
  end
end

# configuration
include_recipe "quantum::_quantum-config"
case node['quantum']['plugin']
when "openvswitch"
	include_recipe "quantum::_ovs-plugin-config"
when "linuxbridge"
	include_recipe "quantum::_lb-plugin-config"
end

# get floating network
floating_if = node['quantum']['floating_if']
external_bridge = node[:quantum][:openvswitch][:external_bridge]

if node['quantum']['plugin'] == "openvswitch"
	execute "create external bridge" do
	  command "ovs-vsctl add-br #{external_bridge};ovs-vsctl add-port #{external_bridge} #{floating_if}"
	  action :run
	  not_if "ovs-vsctl show | grep 'Bridge br-ex'" ## FIXME
	end
end

keystone_admin_endpoint = get_access_endpoint("keystone", "keystone", "admin-api")
metadata_ip = get_access_endpoint("nova-api-metadata", "nova", "api")

template "/etc/quantum/l3_agent.ini" do
        mode "0644"
        owner "quantum"
        group "quantum"
        source "l3_agent.ini.erb"
        variables(
		"interface_driver" => node['quantum']['interface_driver'],
                "keystone_api_ipaddress" => keystone_admin_endpoint['host'],
                "admin_port" => keystone_admin_endpoint['port'],
#               "metadata_ip" => metadata_ip["host"],
                "region" => 'RegionOne',
                "service_tenant_name" => node['quantum']['service_tenant_name'],
                "service_user" => node['quantum']['service_user'],
                "service_pass" => node['quantum']['service_pass'],
                "router_id" => node['quantum']['router_id'],
                "use_namespaces" => node['quantum']['use_namespaces']
        )
        notifies :restart, resources(:service => "quantum-l3-agent")
end

