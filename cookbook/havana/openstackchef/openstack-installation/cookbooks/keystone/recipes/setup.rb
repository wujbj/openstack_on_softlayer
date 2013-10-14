#
# Cookbook Name:: keystone
# Recipe:: setup
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
#include_recipe "keystone::keystone-rsyslog"

platform_options = node["keystone"]["platform"]


#############################################
# secure passwords
#############################################
secure_password = get_passwords("keystone-db-password")
if secure_password.nil?
  secure_password = node["keystone"]["db"]["password"]
end

ret = get_passwords("keystone-admin_token")
if not ret.nil?
  secure_admin_token = ret
else
  secure_admin_token = node["keystone"]["admin_token"]
end

ret = get_passwords("keystone-admin_user-password")
if not ret.nil?
  secure_admin_password = ret
else
  secure_admin_password = node["keystone"]["users"][node["keystone"]["admin_user"]]["password"]
end
#############################################

if node["openstack"]["db"]["service_type"] == "mysql"
  puts 'install mysql python driver'
elsif node["openstack"]["db"]["service_type"] == "db2"
  include_recipe "db2::odbc_install"
end

#include_recipe "monitoring"

# Allow for using a well known db password
if node["developer_mode"]
  #node.set_unless["keystone"]["db"]["password"] = "keystone"
  #node.set_unless["keystone"]["admin_token"] = "999888777666"
  #node.set_unless["keystone"]["users"]["monitoring"]["password"] = "monitoring"
else
  #secure_password = "password"
  #node.set_unless["keystone"]["db"]["password"] = secure_password
  #node.set_unless["keystone"]["admin_token"] = secure_password
  #node.set_unless["keystone"]["users"]["monitoring"]["password"] = secure_password
end


##### NOTE #####
# https://bugs.launchpad.net/ubuntu/+source/keystone/+bug/931236 (Resolved)
# https://bugs.launchpad.net/ubuntu/+source/keystone/+bug/1073273
################

platform_options["keystone_packages"].each do |pkg|
  package pkg do
    action :upgrade
    options platform_options["package_options"]
  end
end

platform_options["keystone_ldap_packages"].each do |pkg|
  package pkg do
    action :upgrade
    options platform_options["package_options"]
  end
end

execute "Keystone: sleep" do
  command "sleep 5s"
  action :nothing
end

service "keystone" do
  service_name platform_options["keystone_service"]
  supports :status => true, :restart => true
  action [ :enable ]
  notifies :run, resources(:execute => "Keystone: sleep"), :immediately
end

#monitoring_procmon "keystone" do
#  procname=platform_options["keystone_service"]
#  sname=platform_options["keystone_process_name"]
#  process_name sname
#  script_name procname
#end

#monitoring_metric "keystone-proc" do
#  type "proc"
#  proc_name "keystone"
#  proc_regex platform_options["keystone_service"]
#  alarms(:failure_min => 2.0)
#end

directory "/etc/keystone" do
  action :create
  owner "root"
  group "root"
  mode "0755"
end

#include_recipe "openstack-patch::keystone"

execute "keystone-manage db_sync" do
  command "keystone-manage db_sync"
  action :nothing
end

ks_admin_endpoint = get_bind_endpoint("keystone", "admin-api", nil, "endpoint")
ks_service_endpoint = get_bind_endpoint("keystone", "service-api", nil, "endpoint")

if not node['package_component'].nil?
  release = node['package_component']
else
  release = "essex-final"
end

db_connection = get_db_connection(node["openstack"]["db"]["service_type"], node["keystone"]["db"]["name"], node["keystone"]["db"]["username"], secure_password)

#template "/etc/sysconfig/keystone" do
#  source "#{release}/keystone.erb"
#  owner "root"
#  group "root"
#  mode "0644"
#  action :nothing
#end

if node["ha_type"].nil?
  ip_address = "0.0.0.0"
else
  ip_address = ks_admin_endpoint["host"]
end

template "/etc/keystone/keystone.conf" do
  ## puts "============ RELEASE #{release}======="
  source "#{release}/keystone.conf.erb"
  owner "root"
  group "root"
  mode "0644"

  variables(
            :debug => node["keystone"]["debug"],
            :verbose => node["keystone"]["verbose"],
            :user => node["keystone"]["db"]["username"],
            :passwd => secure_password,
            :ip_address => ip_address,
            :service_port => ks_service_endpoint["port"],
            :admin_port => ks_admin_endpoint["port"],
            :admin_token => secure_admin_token,
            :use_syslog => node["keystone"]["syslog"]["use"],
            :log_facility => node["keystone"]["syslog"]["facility"],
	        :auth_type => node["keystone"]["auth_type"],
	        :ldap_options => node["keystone"]["ldap"],
	        :db_connection => db_connection
            )
#  notifies :create, resources(:template => "/etc/sysconfig/keystone"), :immediately
#  ["keystone", "python-keystoneclient"].each do |com|
#    notifies :run, resources(:execute => "sh #{com}.sh"), :immediately
#    notifies :run, resources(:execute => "patch #{com}.patch"), :immediately
#  end
  notifies :run, resources(:execute => "keystone-manage db_sync"), :immediately
  notifies :restart, resources(:service => "keystone"), :immediately
end
