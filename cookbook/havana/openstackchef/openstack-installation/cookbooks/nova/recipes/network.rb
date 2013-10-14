#
# Cookbook Name:: nova
# Recipe:: network
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

include_recipe "nova::nova-common"
include_recipe "nova::api-metadata"
#include_recipe "monitoring"

# Public interface needs to be the bridge if the public interface is in the bridge
if node["nova"]["networks"][0]["bridge_dev"] == node["nova"]["network"]["public_interface"]
  node.set["nova"]["network"]["public_interface"] = node["nova"]["networks"][0]["bridge"]
end

if not node['package_component'].nil?
  release = node['package_component']
else
  release = "essex-final"
end

platform_options = node["nova"]["platform"][release]

platform_options["nova_network_packages"].each do |pkg|
  package pkg do
    action :upgrade
    retries 5
    retry_delay 10
    options platform_options["package_overrides"]
  end
end

service "nova-network" do
  service_name platform_options["nova_network_service"]
  supports :status => true, :restart => true
  action :enable
  subscribes :restart, resources(:template => "/etc/nova/nova.conf"), :delayed
end

#monitoring_procmon "nova-network" do
#  service_name=platform_options["nova_network_service"]
#  process_name "nova-network"
#  script_name service_name
#end

#monitoring_metric "nova-network-proc" do
#  type "proc"
#  proc_name "nova-network"
#  proc_regex platform_options["nova_network_service"]
#
#  alarms(:failure_min => 2.0)
#end

if node["network_type"] != "quantum"
  if node["nova"]["network"]["network_manager"] != "nova.network.manager.VlanManager"
    node["nova"]["networks"].each do |net|
      execute "nova-manage network create --label=#{net['label']}" do
       	command "nova-manage network create --multi_host='T' --label=#{net['label']} --fixed_range_v4=#{net['ipv4_cidr']} --num_networks=#{net['num_networks']} --network_size=#{net['network_size']} --bridge=#{net['bridge']} --bridge_interface=#{net['bridge_dev']} --dns1=#{net['dns1']} --dns2=#{net['dns2']}"
       	#command "nova-manage network create --multi_host='T' --label=#{net['label']} --fixed_range_v4=#{net['ipv4_cidr']} --num_networks=#{net['num_networks']} --network_size=#{net['network_size']} --bridge=#{net['bridge']} --dns1=#{net['dns1']} --dns2=#{net['dns2']}"
       	action :run
       	not_if "nova-manage network list | grep #{net['ipv4_cidr']}"
      end
    end
  end

  if node.has_key?(:floating) and node["floating"] == true and node["nova"]["network"]["floating"].has_key?(:ipv4_cidr) and node["nova"]["network"]["floating"]["ipv4_cidr"]
    execute "nova-manage floating create" do
      command "nova-manage floating create --pool=#{node["nova"]["network"]["floating_pool_name"]} --ip_range=#{node["nova"]["network"]["floating"]["ipv4_cidr"]}"
      action :run
      only_if "nova-manage floating list | grep \"No floating IP addresses have been defined.\""
 #  not_if "nova --os-username #{keystone_admin_user} --os-auth-url #{ks_service_endpoint["uri"]} --os-tenant-name #{keystone_admin_tenant} --os-password #{keystone_admin_password} floating-ip-pool-list|grep #{node["nova"]["network"]["floating_pool_name"]}"
    end
  end
end

service "nova-compute" do
  service_name platform_options["nova_compute_service"]
  action :restart
end
