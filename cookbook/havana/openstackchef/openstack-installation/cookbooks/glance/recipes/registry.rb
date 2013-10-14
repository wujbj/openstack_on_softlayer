#
# Cookbook Name:: glance
# Recipe:: registry
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

#::Chef::Recipe.send(:include, Opscode::OpenSSL::Password)
include_recipe "osops-utils"


if node["openstack"]["db"]["service_type"] == "mysql"
  puts 'install mysql python driver'
elsif node["openstack"]["db"]["service_type"] == "db2"
  include_recipe "db2::odbc_install"
end

#include_recipe "glance::glance-rsyslog"
#include_recipe "monitoring"

if not node['package_component'].nil?
    release = node['package_component']
else
    release = "essex-final"
end

platform_options = node["glance"]["platform"][release]

#secure_password = "glance"

# Allow for using a well known db password
#if node["developer_mode"]
#  node.set_unless['glance']['db']['password'] = "glance"
#else
#  node.set_unless['glance']['db']['password'] = secure_db_password
#end

# Set a secure keystone service password
#node.set_unless['glance']['service_pass'] = secure_password

# get secure glance service password from encrypted databag if it exists
ret = get_passwords("glance-service-password")
if not ret.nil?
  secure_service_password = ret
else
  secure_service_password = node["glance"]["service_pass"]
end


package "python-keystone" do
  action :install
  retries 5
  retry_delay 10
end

ks_admin_endpoint = get_access_endpoint("keystone", "keystone", "admin-api", "endpoint")
ks_service_endpoint = get_access_endpoint("keystone", "keystone", "service-api", "endpoint")
keystone = get_settings_by_role("keystone", "keystone")

registry_endpoint = get_bind_endpoint("glance", "registry", nil, "endpoint")

package "curl" do
  action :install
  retries 5
  retry_delay 10
end

platform_options["mysql_python_packages"].each do |pkg|
  package pkg do
    action :install
    retries 5
    retry_delay 10
  end
end

platform_options["glance_packages"].each do |pkg|
  package pkg do
    action :upgrade
    retries 5
    retry_delay 10
    options platform_options["package_overrides"]
  end
end

service "glance-registry" do
  service_name platform_options["glance_registry_service"]
  supports :status => true, :restart => true
  action :nothing
end

#monitoring_procmon "glance-registry" do
#  sname = platform_options["glance_registry_service"]
#  pname = platform_options["glance_registry_process_name"]
#  process_name pname
#  script_name sname
#end

#monitoring_metric "glance-registry-proc" do
#  type "proc"
#  proc_name "glance-registry"
#  proc_regex platform_options["glance_registry_service"]
#
#  alarms(:failure_min => 2.0)
#end

file "/var/lib/glance/glance.sqlite" do
    action :delete
end


ret = get_passwords("keystone-admin_token")
if not ret.nil?
  secure_keystone_admin_token = ret
else
  secure_keystone_admin_token = keystone["admin_token"]
end

# Register Service Tenant
keystone_tenant "Register Service Tenant" do
  auth_host ks_admin_endpoint["host"]
  auth_port ks_admin_endpoint["port"]
  auth_protocol ks_admin_endpoint["scheme"]
  api_ver ks_admin_endpoint["path"]
  auth_token secure_keystone_admin_token
  tenant_name node["glance"]["service_tenant_name"]
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
  auth_token secure_keystone_admin_token
  tenant_name node["glance"]["service_tenant_name"]
  user_name node["glance"]["service_user"]
  user_pass secure_service_password
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
  auth_token secure_keystone_admin_token
  tenant_name node["glance"]["service_tenant_name"]
  user_name node["glance"]["service_user"]
  role_name node["glance"]["service_role"]
  action :grant
end

directory "/etc/glance" do
  action :create
  #group "glance"
  #owner "glance"
  mode "0700"
end

execute "chown etc_glance" do
  command "chown -R glance:glance /etc/glance"
  action :run
end

db_user = node["openstack"]["image"]["db"]["username"]
db_pass = db_password "glance"
db_connection = db_uri("image", db_user, db_pass)

template "/etc/glance/glance-registry.conf" do
  source "#{release}/glance-registry.conf.erb"
  owner "root"
  group "root"
  mode "0644"
  variables(
    "debug" => node["glance"]["debug"],
    "verbose" => node["glance"]["verbose"],
    "registry_bind_address" => registry_endpoint["host"],
    "registry_port" => registry_endpoint["port"],
    "db_connection" => db_connection,
    "use_syslog" => node["glance"]["syslog"]["use"],
    "log_facility" => node["glance"]["syslog"]["facility"]
  )
end


execute "glance-manage db_sync" do
  #if platform?(%w{ubuntu debian})
  #  command "sudo -u glance glance-manage version_control 0 && sudo -u glance glance-manage db_sync"
  #end
  #if platform?(%w{redhat centos fedora scientific})
  command "glance-manage db_sync"
  #end
  #not_if "sudo -u glance glance-manage db_version"
  action :run
end

execute "chown var_log_glance" do
  command "chown -R glance:glance /var/log/glance"
  action :run
end

template "/etc/glance/glance-registry-paste.ini" do
  source "#{release}/glance-registry-paste.ini.erb"
  owner "root"
  group "root"
  mode "0644"
  variables(
    "keystone_api_ipaddress" => ks_admin_endpoint["host"],
    "keystone_service_port" => ks_service_endpoint["port"],
    "keystone_admin_port" => ks_admin_endpoint["port"],
    "service_tenant_name" => node["glance"]["service_tenant_name"],
    "service_user" => node["glance"]["service_user"],
    "service_pass" => secure_service_password
  )
  notifies :restart, resources(:service => "glance-registry"), :immediately
  notifies :enable, resources(:service => "glance-registry"), :immediately
end

#patch_openstack(node["openstack_patch_url"], "glance")

if node["iptables"]["enabled"] == true
  iptables_rule "port_glanceregistry"
end

