#
# Cookbook Name:: nova
# Recipe:: api-os-compute
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

#::Chef::Recipe.send(:include, Opscode::OpenSSL::Password)
include_recipe "nova::nova-common"
#include_recipe "monitoring"

secure_password = "password"

# Set a secure keystone service password
node.set_unless['nova']['service_pass'] = secure_password

if not node['package_component'].nil?
  release = node['package_component']
else
  release = "essex-final"
end

platform_options = node["nova"]["platform"][release]

directory "/var/lock/nova" do
  #owner "nova"
  #roup "nova"
  mode "0755"
  action :create
end

execute "chown var_lock_nova_api_compute" do
  command "chown -R nova:nova /var/lock/nova"
  action :run
end

package "python-keystone" do
  action :upgrade
  retries 5
  retry_delay 10
end

platform_options["api_os_compute_packages"].each do |pkg|
  package pkg do
    action :upgrade
    retries 5
    retry_delay 10
    options platform_options["package_overrides"]
  end
end

service "nova-api-os-compute" do
  service_name platform_options["api_os_compute_service"]
  supports :status => true, :restart => true
  action :enable
  subscribes :restart, resources(:template => "/etc/nova/nova.conf"), :delayed
end

#monitoring_procmon "nova-api-os-compute" do
#  service_name=platform_options["api_os_compute_service"]
#  pname=platform_options["api_os_compute_process_name"]
#  process_name pname
#  script_name service_name
#end

#monitoring_metric "nova-api-os-compute-proc" do
#  type "proc"
#  proc_name "nova-api-os-compute"
#  proc_regex platform_options["api_os_compute_service"]

#  alarms(:failure_min => 2.0)
#end

keystone = get_settings_by_role("keystone", "keystone")
ks_admin_endpoint = get_access_endpoint("keystone", "keystone", "admin-api", "endpoint")
ks_service_endpoint = get_access_endpoint("keystone", "keystone", "service-api", "endpoint")

#nova_api_endpoint = get_access_endpoint("nova-api-os-compute", "nova", "api", "endpoint")

api_endpoint = get_bind_endpoint("nova", "api")
api_internal_endpoint = get_bind_endpoint("nova", "internal-api")
api_admin_endpoint = get_bind_endpoint("nova", "admin-api")


# Register Service Tenant
keystone_tenant "Register Service Tenant" do
  auth_host ks_admin_endpoint["host"]
  auth_port ks_admin_endpoint["port"]
  auth_protocol ks_admin_endpoint["scheme"]
  api_ver ks_admin_endpoint["path"]
  auth_token keystone["admin_token"]
  tenant_name node["nova"]["service_tenant_name"]
  tenant_description "Service Tenant"
  tenant_enabled "true" # Not required as this is the default
  action :create
end

# Register Service User
keystone_user "Register Service User" do
  auth_host ks_admin_endpoint["host"]
  auth_port ks_admin_endpoint["port"]
  auth_protocol ks_admin_endpoint["scheme"]
  api_ver ks_admin_endpoint["path"]
  auth_token keystone["admin_token"]
  tenant_name node["nova"]["service_tenant_name"]
  user_name node["nova"]["service_user"]
  user_pass node["nova"]["service_pass"]
  if node['package_component'] == "folsom"
    user_enabled "true"
  else
    user_enabled "1" # Not required as this is the default
  end
  action :create
end

## Grant Admin role to Service User for Service Tenant ##
keystone_role "Grant 'admin' Role to Service User for Service Tenant" do
  auth_host ks_admin_endpoint["host"]
  auth_port ks_admin_endpoint["port"]
  auth_protocol ks_admin_endpoint["scheme"]
  api_ver ks_admin_endpoint["path"]
  auth_token keystone["admin_token"]
  tenant_name node["nova"]["service_tenant_name"]
  user_name node["nova"]["service_user"]
  role_name node["nova"]["service_role"]
  action :grant
end

# Register Compute Service
keystone_service "Register Compute Service" do
  auth_host ks_admin_endpoint["host"]
  auth_port ks_admin_endpoint["port"]
  auth_protocol ks_admin_endpoint["scheme"]
  api_ver ks_admin_endpoint["path"]
  auth_token keystone["admin_token"]
  service_name "nova"
  service_type "compute"
  service_description "Nova Compute Service"
  action :create
end


execute "nova secgroup-add-rule default tcp 22 22 0.0.0.0/0" do
  command "sleep 5; source /root/openrc; nova secgroup-add-rule default tcp 22 22 0.0.0.0/0; nova secgroup-add-rule default icmp -1 -1 0.0.0.0/0"
  ignore_failure true
  returns [0, 1]
  action :nothing
  subscribes :run, resources(:service => "nova-api-os-compute"), :delayed
  only_if { File.exists? "/root/openrc" }
  #not_if "! nova secgroup-list-rules default"
end

template "/etc/nova/api-paste.ini" do
  source "#{release}/api-paste.ini.erb"
  owner "root"
  group "root"
  mode "0644"
  variables(
            "component"  => node["package_component"],
            "keystone_api_ipaddress" => ks_service_endpoint["host"],
            "service_port" => ks_service_endpoint["port"],
            "admin_port" => ks_admin_endpoint["port"],
            "admin_token" => keystone["admin_token"]
            )
  notifies :restart, resources(:service => "nova-api-os-compute"), :delayed
end

# Register Compute Endpoing
keystone_endpoint "Register Compute Endpoint" do
  auth_host ks_admin_endpoint["host"]
  auth_port ks_admin_endpoint["port"]
  auth_protocol ks_admin_endpoint["scheme"]
  api_ver ks_admin_endpoint["path"]
  auth_token keystone["admin_token"]
  service_type "compute"
  endpoint_region node["nova"]["compute"]["region"]
  endpoint_adminurl api_admin_endpoint["uri"]
  endpoint_internalurl api_internal_endpoint["uri"]
  endpoint_publicurl api_endpoint["uri"]
  action :create
end

#if node["iptables"]["enabled"] == true
#  iptables_rule "port_novaapi"
#  iptables_rule "port_novametadata"
#end
