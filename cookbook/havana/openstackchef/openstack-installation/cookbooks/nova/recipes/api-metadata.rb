#
# Cookbook Name:: nova
# Recipe:: api-metadata
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
#include_recipe "monitoring"

if not node['package_component'].nil?
  release = node['package_component']
else
  release = "essex-final"
end

platform_options = node["nova"]["platform"][release]

directory "/var/lock/nova" do
    #owner "nova"
    #group "nova"
    mode "0755"
    action :create
end

execute "chown var_lock_nova_api_mb" do
  command "chown -R nova:nova /var/lock/nova"
  action :run
end


package "python-keystone" do
  action :upgrade
  retries 5
  retry_delay 10
end

platform_options["nova_api_metadata_packages"].each do |pkg|
  package pkg do
    action :upgrade
    retries 5
    retry_delay 10
    options platform_options["package_overrides"]
  end
end

service "nova-api-metadata" do
  service_name platform_options["nova_api_metadata_service"]
  supports :status => true, :restart => true
  action :enable
  subscribes :restart, resources(:template => "/etc/nova/nova.conf"), :delayed
end

#monitoring_procmon "nova-api-metadata" do
#  service_name = platform_options["nova_api_metadata_service"]
#  process_name "nova-api-metadata"
#  script_name service_name
#end

#monitoring_metric "nova-api-metadata-proc" do
#  type "proc"
#  proc_name "nova-api-metadata"
#  proc_regex platform_options["nova_api_metadata_service"]
#
#  alarms(:failure_min => 2.0)
#end

ks_admin_endpoint = get_access_endpoint("keystone", "keystone", "admin-api", "endpoint")
ks_service_endpoint = get_access_endpoint("keystone", "keystone", "service-api", "endpoint")
keystone = get_settings_by_role("keystone","keystone")

template "/etc/nova/api-paste.ini" do
  source "#{release}/api-paste.ini.erb"
  owner "root"
  group "root"
  mode "0644"
  variables(
    "component"  => node["package_component"],
    "keystone_api_ipaddress" => ks_admin_endpoint["host"],
    "admin_port" => ks_admin_endpoint["port"],
    "service_port" => ks_service_endpoint["port"],
    "admin_token" => keystone["admin_token"]
  )
  notifies :restart, resources(:service => "nova-api-metadata"), :delayed
end

#if node["iptables"]["enabled"] == true
#  iptables_rule "port_novametadata"
#end
