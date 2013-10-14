#
# Cookbook Name:: quantum
# Recipe:: _quantum-config
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

keystone_service_endpoint = get_access_endpoint("keystone", "keystone", "service-api")
bind_endpoint = get_bind_endpoint("quantum", "admin-api")

## Get MQ info
mq_info = get_access_endpoint("os-ops-messaging","mq","mq")

if mq_info.nil?
    puts mq_info
    puts "Get MQ info error"
    exit(1)
end
if node['mq_ha']
    mq_info['host'] = node['mq']['vip']
end

case node['quantum']['plugin']
when "openvswitch"
	core_plugin = "quantum.plugins.openvswitch.ovs_quantum_plugin.OVSQuantumPluginV2"
when "linuxbridge"
	core_plugin = "quantum.plugins.linuxbridge.lb_quantum_plugin.LinuxBridgePluginV2"
when "nvp"
	core_plugin = "nvp"
end

template "/etc/quantum/quantum.conf" do
	source "quantum.conf.erb"
#	owner "quantum"
#	group "quantum"
	mode "0644"
	variables(
		"bind_host" => bind_endpoint["host"],
		"bind_port" => bind_endpoint["port"],
		"core_plugin" => core_plugin,
    "qpid_ipaddress" => mq_info["host"],
    "qpid_port" => mq_info["port"],
    "rabbit_ipaddress" => mq_info["host"],
    "rabbit_port" => mq_info["port"],
    "keystone_ipaddress" => keystone_service_endpoint["host"],
    "keystone_port" => keystone_service_endpoint["port"],
    "quota_port" => node[:quantum][:quota_port],
    "allow_overlapping_ips" => node[:quantum][:allow_overlapping_ips]
	)
end

