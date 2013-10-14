#
# Cookbook Name:: glance
# Recipe:: api
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

#include_recipe "glance::glance-rsyslog"
#include_recipe "monitoring"
include_recipe "osops-utils"

if not node['package_component'].nil?
    release = node['package_component']
else
    release = "essex-final"
end


# get glance db password from encrypted databag if it exists. Otherwise, use password
# from environment file
ret = get_passwords("glance-db-password")
if not ret.nil?
  secure_db_password = ret
else
  secure_db_password = node["glance"]["db"]["password"]
end


platform_options = node["glance"]["platform"][release]

if node["openstack"]["db"]["service_type"] == "db2"
  include_recipe "db2::odbc_install"
end

package "curl" do
  action :upgrade
  retries 5
  retry_delay 10
end

package "python-keystone" do
  action :install
  retries 5
  retry_delay 10
end

platform_options["glance_packages"].each do |pkg|
  package pkg do
    action :upgrade
    retries 5
    retry_delay 10
    options platform_options["package_overrides"]
  end
end

service "glance-api" do
  service_name platform_options["glance_api_service"]
  supports :status => true, :restart => true
  action :enable
end

#monitoring_procmon "glance-api" do
#  sname = platform_options["glance_api_service"]
#  pname = platform_options["glance_api_process_name"]
#  process_name pname
#  script_name sname
#end

#monitoring_metric "glance-api-proc" do
#  type "proc"
#  proc_name "glance-api"
#  proc_regex platform_options["glance_api_service"]
#
#  alarms(:failure_min => 2.0)
#end

directory "/etc/glance" do
  action :create
  #group "glance"
  #owner "glance"
  mode "0700"
end

execute "chown etc_glance_api" do
  command "chown -R glance:glance /etc/glance"
  action :run
end


# FIXME: seems like misfeature
template "/etc/glance/policy.json" do
  source "policy.json.erb"
  owner "root"
  group "root"
  mode "0644"
  notifies :restart, resources(:service => "glance-api"), :immediately
  not_if do
    File.exists?("/etc/glance/policy.json")
  end
end

## Get MQ info
mq_info = get_access_endpoint("os-ops-messaging","mq","mq")

if mq_info.nil?
    puts mq_info
    puts "Get MQ info error"
    exit(1)
end
if node['openstack']['mq']['cluster']
    mq_info['host'] = node['openstack']['mq']['vip']
end

ks_admin_endpoint = get_access_endpoint("keystone", "keystone", "admin-api", "endpoint")
ks_service_endpoint = get_access_endpoint("keystone", "keystone","service-api", "endpoint")
keystone = get_settings_by_role("keystone", "keystone")
glance = get_settings_by_role("glance", "glance")
registry = get_settings_by_role("glance", "glance")

registry_endpoint = get_access_endpoint("glance", "glance", "registry", "endpoint")
#registry_endpoint = get_bind_endpoint("glance", "admin-api")

api_endpoint = get_bind_endpoint("glance", "api")
internal_api_endpoint = get_bind_endpoint("glance", "internal-api")
admin_api_endpoint = get_bind_endpoint("glance", "admin-api")

# get secure glance service password from encrypted databag if it exists
ret = get_passwords("glance-service-password")
if not ret.nil?
  secure_service_password = ret
else
  secure_service_password = node["glance"]["service_pass"]
end


# Possible combinations of options here
# - default_store=file
#     * no other options required
# - default_store=swift
#     * if swift_store_auth_address is not defined
#         - default to local swift
#     * else if swift_store_auth_address is defined
#         - get swift_store_auth_address, swift_store_user, swift_store_key, and
#           swift_store_auth_version from the node attributes and use them to connect
#           to the swift compatible API service running elsewhere - possibly
#           Rackspace Cloud Files.

if glance["api"]["swift_store_auth_address"].nil?
    swift_store_auth_address="http://#{ks_admin_endpoint["host"]}:#{ks_service_endpoint["port"]}/v2.0"
    swift_store_user="#{glance["service_tenant_name"]}:#{glance["service_user"]}"
    swift_store_key=secure_service_password
    swift_store_auth_version=2
else
    swift_store_auth_address=registry["api"]["swift_store_auth_address"]
    swift_store_user=registry["api"]["swift_store_user"]
    swift_store_key=registry["api"]["swift_store_key"]
    swift_store_auth_version=registry["api"]["swift_store_auth_version"]
end

# Only use the glance image cacher if we aren't using file for our backing store.
if glance["api"]["default_store"]=="file"
  glance_flavor="keystone"
else
  glance_flavor="keystone+cachemanagement"
end

db_user = node["openstack"]["image"]["db"]["username"]
db_pass = db_password "glance"
db_connection = db_uri("image", db_user, db_pass)

template "/etc/glance/glance-api.conf" do
  source "#{release}/glance-api.conf.erb"
  owner "root"
  group "root"
  mode "0644"
  variables(
    "debug" => node["glance"]["debug"],
    "verbose" => node["glance"]["verbose"],
    "api_bind_address" => api_endpoint["host"],
    "api_bind_port" => api_endpoint["port"],
    "registry_ip_address" => registry_endpoint["host"],
    "registry_port" => registry_endpoint["port"],
    "use_syslog" => node["glance"]["syslog"]["use"],
    "log_facility" => node["glance"]["syslog"]["facility"],
    "rabbit_ipaddress" => mq_info["host"],
    "rabbit_port" => mq_info["port"],
    "qpid_ipaddress" => mq_info["host"],
    "qpid_port" => mq_info["port"],
    "notifier_strategy" => node["glance"]["notifier_strategy"],
    "default_store" => glance["api"]["default_store"],
    "glance_flavor" => glance_flavor,
    "swift_store_key" => swift_store_key,
    "swift_store_user" => swift_store_user,
    "swift_store_auth_address" => swift_store_auth_address,
    "swift_store_auth_version" => swift_store_auth_version,
    "swift_large_object_size" => glance["api"]["swift"]["store_large_object_size"],
    "swift_large_object_chunk_size" => glance["api"]["swift"]["store_large_object_chunk_size"],
    "swift_store_container" => glance["api"]["swift"]["store_container"],
    "db_connection" => db_connection
  )
  notifies :restart, resources(:service => "glance-api"), :immediately
end


ret = get_passwords("keystone-admin_token")
if not ret.nil?
  secure_keystone_admin_token = ret
else
  secure_keystone_admin_token = keystone["admin_token"]
end

template "/etc/glance/glance-api-paste.ini" do
  source "#{release}/glance-api-paste.ini.erb"
  owner "root"
  group "root"
  mode "0644"
  variables(
    "keystone_api_ipaddress" => ks_admin_endpoint["host"],
    "keystone_service_port" => ks_service_endpoint["port"],
    "keystone_admin_port" => ks_admin_endpoint["port"],
    "keystone_admin_token" => secure_keystone_admin_token,
    "service_tenant_name" => registry["service_tenant_name"],
    "service_user" => registry["service_user"],
    "service_pass" => secure_service_password
  )
  notifies :restart, resources(:service => "glance-api"), :immediately
end

template "/etc/glance/glance-cache.conf" do
  source "glance-cache.conf.erb"
  owner "root"
  group "root"
  mode "0644"
  variables(
    "registry_ip_address" => registry_endpoint["host"],
    "registry_port" => registry_endpoint["port"],
    "use_syslog" => node["glance"]["syslog"]["use"],
    "log_facility" => node["glance"]["syslog"]["facility"],
    "image_cache_max_size" => node["glance"]["api"]["cache"]["image_cache_max_size"]
  )
  notifies :restart, resources(:service => "glance-api"), :delayed
end

template "/etc/glance/glance-cache-paste.ini" do
  source "glance-cache-paste.ini.erb"
  owner "root"
  group "root"
  mode "0644"
  notifies :restart, resources(:service => "glance-api"), :delayed
end

template "/etc/glance/glance-scrubber.conf" do
  source "glance-scrubber.conf.erb"
  owner "root"
  group "root"
  mode "0644"
  variables(
    "registry_ip_address" => registry_endpoint["host"],
    "registry_port" => registry_endpoint["port"]
  )
end

# Configure glance-cache-pruner to run every 30 minutes
cron "glance-cache-pruner" do
  minute "*/30"
  command "/usr/bin/glance-cache-pruner"
end

# Configure glance-cache-cleaner to run at 00:01 everyday
cron "glance-cache-cleaner" do
  minute "01"
  hour "00"
  command "/usr/bin/glance-cache-cleaner"
end

template "/etc/glance/glance-scrubber-paste.ini" do
  source "glance-scrubber-paste.ini.erb"
  owner "root"
  group "root"
  mode "0644"
end

# Register Image Service

keystone_service "Register Image Service" do
  auth_host ks_admin_endpoint["host"]
  auth_port ks_admin_endpoint["port"]
  auth_protocol ks_admin_endpoint["scheme"]
  api_ver ks_admin_endpoint["path"]
  auth_token secure_keystone_admin_token
  service_name "glance"
  service_type "image"
  service_description "Glance Image Service"
  action :create
end

# Register Image Endpoint
keystone_endpoint "Register Image Endpoint" do
  auth_host ks_admin_endpoint["host"]
  auth_port ks_admin_endpoint["port"]
  auth_protocol ks_admin_endpoint["scheme"]
  api_ver ks_admin_endpoint["path"]
  auth_token secure_keystone_admin_token
  service_type "image"
  endpoint_region "RegionOne"
  endpoint_adminurl admin_api_endpoint["uri"]
  endpoint_internalurl internal_api_endpoint["uri"]
  endpoint_publicurl api_endpoint["uri"]
  action :create
end


# get keystone admin password from encrypted databag
ret = get_passwords("keystone-admin_user-password")
if not ret.nil?
  secure_keystone_admin_user_password = ret
else
  keystone_admin_user = keystone["admin_user"]
  secure_keystone_admin_user_password = keystone["users"][keystone_admin_user]["password"]
end

if node["glance"]["image_upload"]
  node["glance"]["images"].each do |img|
    Chef::Log.info("Checking to see if #{img.to_s}-image should be uploaded.")

    ## fix the second image multi-upload issue
    execute "sleep 3 seconds" do
      command "sleep 2"
      action :run
    end

    keystone_admin_user = keystone["admin_user"]
    keystone_admin_password = secure_keystone_admin_user_password
    keystone_tenant = keystone["users"][keystone_admin_user]["default_tenant"]

    glance_image "Image setup for #{img.to_s}" do
      image_url node["glance"]["image"][img.to_sym]
      image_name img
      keystone_user keystone_admin_user
      keystone_pass keystone_admin_password
      keystone_tenant keystone_tenant
      keystone_uri ks_admin_endpoint["uri"]
      action :upload
    end

  end
end

# set up glance api monitoring (bytes/objects per tentant, etc)
#monitoring_metric "glance-api" do
#  type "pyscript"
#  script "glance_plugin.py"
#  options("Username" => node["glance"]["service_user"],
#          "Password" => node["glance"]["service_pass"],
#          "TenantName" => node["glance"]["service_tenant_name"],
#          "AuthURL" => ks_service_endpoint["uri"] )
#end

if node["iptables"]["enabled"] == true
  iptables_rule "port_glanceapi"
end
