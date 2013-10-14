#
# Cookbook Name:: quantum
# Recipe:: quantum-server
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

#::Chef::Recipe.send(:include, Opscode::OpenSSL::Password)

if node["openstack"]["db"]["service_type"] == "db2"
  include_recipe "db2::odbc_install"
elsif node["openstack"]["db"]["service_type"] == "mysql"
  ## Install MySQL-python
  node['db']['mysql']['packages'].each do |pkg|
    package "#{pkg}" do
      action :install
      retries 5
      retry_delay 10
    end
  end
end

keystone_service_endpoint = get_access_endpoint("keystone", "keystone", "service-api")
keystone_admin_endpoint = get_access_endpoint("keystone", "keystone", "admin-api")
keystone = get_settings_by_role("keystone", "keystone")
keystone_admin_user = keystone['admin_user']
keystone_admin_password = keystone['users'][keystone_admin_user]['password']
keystone_admin_tenant = keystone['users'][keystone_admin_user]['default_tenant']
#rabbit_info = get_access_endpoint("rabbitmq-server", "rabbitmq", "queue")

# Search for AMQP endpoint
rabbit_info = get_access_endpoint("rabbitmq-server", "rabbitmq", "queue")
qpid_info = get_access_endpoint("qpid", "qpid", "queue")
if qpid_info.nil?
    qpid_info = get_access_endpoint("os-ops-messaging", "qpid", "queue")
end

#Check if there is qpid. if not, set to empty
if qpid_info.nil?
  qpid_info = { "host" => "",
                "port" => ""
              }
end
if rabbit_info.nil?
  rabbit_info = { "host" => "",
                "port" => ""
              }
end


Chef::Log.info("keystone service endpoint:  #{keystone_service_endpoint}")
Chef::Log.info("keystone admin endpoint:  #{keystone_admin_endpoint}")
Chef::Log.info("qpid service endpoint:  #{qpid_info}")

# temporary
node.set['quantum']['service_pass'] = "password"

platform_options = node['quantum']['platform']

# install packages for quantum server
platform_options['quantum_server_packages'].each do |pkg|
  package pkg do
    action :upgrade
    options platform_options['package_overrides']
  end
end

# define the quantum-server service so we can call it later
platform_options['quantum_server_services'].each do |svc|
        service svc do
                service_name svc
                supports :status => true, :restart => true
                action :enable
		subscribes :restart, "template[/etc/quantum/quantum.conf]", :delayed
		subscribes :restart, "template[/etc/quantum/api-paste.ini]", :delayed
		subscribes :restart, "template[/etc/quantum/plugin.ini]", :delayed
        end
end

# Customize quantum configuration files
Chef::Log.info("Customizing quantum configuration files...")
include_recipe "quantum::_quantum-config"
include_recipe "quantum::_ovs-plugin-config"

execute "create_links" do
        command "ln -s /etc/quantum/plugins/openvswitch/ovs_quantum_plugin.ini /etc/quantum/plugin.ini"
        action :run
	not_if { ::File.exists?("/etc/quantum/plugin.ini") }
end

#service "quantum-server" do
#	action :restart
#end

# Register quantum service to Keystone
Chef::Log.info("Registering quantum service...")
keystone_register "Register Quantum Service" do
	auth_host keystone_admin_endpoint['host']
	auth_port keystone_admin_endpoint['port']
	auth_protocol keystone_admin_endpoint['scheme']
	api_ver keystone_admin_endpoint['path']
	auth_token keystone['admin_token']
	service_name "quantum"
	service_type "network"
	service_description "Quantum Network Service"
	action :create_service
end

# Register quantum endpoints to Keystone
quantum_server_endpoint = get_bind_endpoint("quantum", "server")
admin_quantum_server_endpoint = get_bind_endpoint("quantum", "admin-api")
internal_quantum_server_endpoint = get_bind_endpoint("quantum", "internal-api")
Chef::Log.info("7. Registering quantum endpoints...url=#{quantum_server_endpoint['uri']}")

keystone_register "Register Network Endpoint" do
	auth_host keystone_admin_endpoint['host']
	auth_port keystone_admin_endpoint['port']
	auth_protocol keystone_admin_endpoint['scheme']
	api_ver keystone_admin_endpoint['path']
	auth_token keystone['admin_token']
	service_type "network"
	endpoint_region "RegionOne"
	endpoint_adminurl admin_quantum_server_endpoint['uri']
	endpoint_internalurl internal_quantum_server_endpoint['uri']
 	endpoint_publicurl quantum_server_endpoint['uri']
	action :create_endpoint
end

# Register service user to Keystone 
Chef::Log.info("Registering service user(assuming 'service' tenant exists)")
keystone_register "Register Service User" do
	auth_host keystone_admin_endpoint['host']
	auth_port keystone_admin_endpoint['port']
	auth_protocol keystone_admin_endpoint['scheme']
	api_ver keystone_admin_endpoint['path']
	auth_token keystone['admin_token']
	tenant_name node['quantum']['service_tenant_name']
	user_name node['quantum']['service_user']
	user_pass node['quantum']['service_pass']
	user_enabled "1"
	action :create_user
end

# Grant admin role to service user for service tenant
Chef::Log.info("Granting admin role to service user for service tenant(assuming admin role exists)")
keystone_register "Grant 'admin' Role to Service User for Service Tenant" do
	auth_host keystone_admin_endpoint['host']
	auth_port keystone_admin_endpoint['port']
	auth_protocol keystone_admin_endpoint['scheme']
	api_ver keystone_admin_endpoint['path']
	auth_token keystone['admin_token']
	tenant_name node['quantum']['service_tenant_name']
	user_name node['quantum']['service_user']
	role_name node['quantum']['service_role']
	action :grant_role
end

if node["iptables"]["enabled"] == true
  iptables_rule "port_quantum"
end
