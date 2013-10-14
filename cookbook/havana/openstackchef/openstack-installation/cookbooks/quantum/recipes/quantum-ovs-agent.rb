#
# Cookbook Name:: quantum
# Recipe:: quantum-ovs-agent
#
# Copyright 2013, Rackspace
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

platform_options = node['quantum']['platform']
ovs_agent_url = node['quantum']['openvswitch']['url']
ovs_agent_package1 = "#{ovs_agent_url}/kmod-openvswitch-1.7.3-1.el6.x86_64.rpm"
ovs_agent_package2 = "#{ovs_agent_url}/openvswitch-1.7.3-1.x86_64.rpm"

case node[:platform]
when "fedora", "redhat", "centos"

	remote_file "/tmp/kmod-openvswitch-1.7.3-1.el6.x86_64.rpm" do
	  source "#{ovs_agent_package1}"
	  mode "0644"
	  action :create_if_missing
	end

	remote_file "/tmp/openvswitch-1.7.3-1.x86_64.rpm" do
	  source "#{ovs_agent_package2}"
	  mode "0644"
	  action :create_if_missing
	end

	package "kmod-openvswitch" do
	  source "/tmp/kmod-openvswitch-1.7.3-1.el6.x86_64.rpm"
	  action :upgrade
	end

	package "openvswitch" do
	  source "/tmp/openvswitch-1.7.3-1.x86_64.rpm"
	  action :upgrade
	end

	service "openvswitch" do
	  service_name  "openvswitch"
    	  supports :status => true, :restart => true
    	  action :enable
    	end

end

platform_options['quantum_ovs_agent_packages'].each do |pkg|
  package pkg do
    action :upgrade
    options platform_options['package_overrides']
  end
end

platform_options['quantum_ovs_agent_services'].each do |svc|
        service svc do
                service_name svc
                supports :status => true, :restart => true
                action :enable
        end
end

# Customize quantum agent config files
include_recipe "quantum::_quantum-config"
include_recipe "quantum::_ovs-plugin-config"

execute "create_links" do
        command "ln -s /etc/quantum/plugins/openvswitch/ovs_quantum_plugin.ini /etc/quantum/plugin.ini"
        action :run
	not_if { ::File.exists?("/etc/quantum/plugin.ini") }
end

# Start quantum agent services
service "quantum-openvswitch-agent" do
	action :restart
	only_if { node['roles'].include?("quantum-ovs-agent") }
end

service "openvswitch" do
	action :restart
	only_if { node['roles'].include?("quantum-ovs-agent") }
end

# 4. Remove bridge module
#Chef::Log.info("4. Removing bridge modules...")
execute "remove_bridge_module" do
        command "rmmod bridge;echo 'blacklist bridge' >> /etc/modprobe.d/blacklist.conf"
        ignore_failure true
	not_if "test 'bridge' != `lsmod | cut -d' ' -f1 | grep bridge`"
        action :run
end


# Create bridges
map_nic = node[:quantum][:openvswitch][:bridge_mapping_nic]
ovs_bridge = node[:quantum][:openvswitch][:integration_bridge]

#if node[:quantum][:openvswitch][:tenant_network_type] == "gre"
#	ovs_bridge = node[:quantum][:openvswitch][:tunnel_bridge]
#end

execute "create_bridges" do
	command "if ! ovs-vsctl list-br | grep #{ovs_bridge}; then ovs-vsctl add-br #{ovs_bridge}; fi; if ! ovs-vsctl list-br | grep br-vmnet; then ovs-vsctl add-br br-vmnet; ovs-vsctl add-port br-vmnet #{map_nic}; fi;"
	action :run
end
