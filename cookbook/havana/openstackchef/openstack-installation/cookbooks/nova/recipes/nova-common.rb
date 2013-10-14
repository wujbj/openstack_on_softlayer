#
# Cookbook Name:: nova
# Recipe:: nova-common
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


#include_recipe "nova::nova-rsyslog"
include_recipe "osops-utils::autoetchosts"

if node["openstack"]["db"]["service_type"] == "db2"
  include_recipe "db2::odbc_install"
end

if not node['package_component'].nil?
  release = node['package_component']
else
  release = "essex-final"
end

platform_options = node["nova"]["platform"][release]

platform_options["common_packages"].each do |pkg|
  package pkg do
    action :upgrade
    retries 5
    retry_delay 10
    options platform_options["package_overrides"]
  end
end

directory "/etc/nova" do
  action :create
  #owner "nova"
  #group "nova"
  mode "0755"
end

execute "chown etc_nova_compute" do
  command "chown -R nova:nova /etc/nova"
  action :run
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

keystone = get_settings_by_role("keystone", "keystone")

# find the node attribute endpoint settings for the server holding a given role
ks_admin_endpoint = get_access_endpoint("keystone", "keystone", "admin-api", "endpoint")
ks_service_endpoint = get_access_endpoint("keystone", "keystone", "service-api", "endpoint")
#xvpvnc_endpoint = get_access_endpoint("nova-vncproxy", "nova", "xvpvnc")
#novnc_endpoint = get_access_endpoint("nova-vncproxy", "nova", "novnc-server")
#novnc_proxy_endpoint = get_bind_endpoint("nova", "novnc")

# NOTE:(mancdaz) we need to account for potentially many glance-api servers here, until
# https://bugs.launchpad.net/nova/+bug/1084138 is fixed
glance_endpoints = get_realserver_endpoints("glance", "glance", "api", "endpoint")
glance_servers = glance_endpoints.each.inject([]) {|output, k| output << [k['host'],k['port']].join(":") }
glance_serverlist = glance_servers.join(",")

nova_api_endpoint = get_access_endpoint("nova-api", "nova", "api", "endpoint")
ec2_public_endpoint = get_access_endpoint("ec2-api", "ec2", "api", "endpoint")

if nova_api_endpoint.nil?
  nova_api_endpoint = {
    "host" => "",
	"port" => ""
  }
end

if ec2_public_endpoint.nil?
  ec2_public_endpoint = {
    "host" => "",
	"port" => ""
  }
end

quantum_info = ""
if node["network_type"] == "quantum"
  quantum_info = get_access_endpoint("quantum-server", "quantum", "server", "endpoint")
else
   Chef::Log.info("Network type is #{node["network_type"]}")
end

if not node['package_component'].nil?
  release = node['package_component']
else
  release = "essex-final"
end

## db_connection = get_db_connection(node["openstack"]["db"]["service_type"], node["nova"]["db"]["name"], node["nova"]["db"]["username"], nova_setup_info["db"]["password"])

db_user = node["openstack"]["compute"]["db"]["username"]
db_pass = db_password "nova"
db_connection = db_uri("compute", db_user, db_pass)

#db_connection = get_db_connection(node["openstack"]["db"]["service_type"], node["nova"]["db"]["name"], node["nova"]["db"]["username"], secure_db_password)

#include_recipe "openstack-patch::nova"

# TODO: need to re-evaluate this for accuracy
template "/etc/nova/nova.conf" do
  source "#{release}/nova.conf.erb"
  owner "root"
  group "root"
  mode "0644"
  variables(
    "debug" => node["nova"]["debug"],
    "verbose" => node["nova"]["verbose"],
    "use_syslog" => node["nova"]["syslog"]["use"],
    "log_facility" => node["nova"]["syslog"]["facility"],
    "db_connection" => db_connection,
    "network_type" => node["network_type"],
    "quantum_agent" => node["quantum"]["plugin"],
#    "vncserver_listen" => "0.0.0.0",
#    "vncserver_proxyclient_address" => novnc_proxy_endpoint["host"],
#    "novncproxy_base_url" => novnc_endpoint["uri"],
#    "xvpvncproxy_bind_host" => xvpvnc_endpoint["host"],
#    "xvpvncproxy_bind_port" => xvpvnc_endpoint["port"],
#    "xvpvncproxy_base_url" => xvpvnc_endpoint["uri"],
    "instances_path" => node["nova"]["instances_path"],
    "state_path" => node["nova"]["state_path"],
    "rabbit_ipaddress" => mq_info["host"],
    "rabbit_port" => mq_info["port"],
    "qpid_ipaddress" => mq_info["host"],
    "qpid_port" => mq_info["port"],
    "libvirt_images_type" => node["nova"]["libvirt_images_type"],
    "use_cow_images" => node["nova"]["use_cow_images"],
    "notify_on_state_change" => node["nova"]["notify_on_state_change"],
    "notification_driver" => node["nova"]["notification_driver"],
    "keystone_api_ipaddress" => ks_admin_endpoint["host"],
    "keystone_service_port" => ks_service_endpoint["port"],
    "glance_serverlist" => glance_serverlist,
    "iscsi_helper" => platform_options["iscsi_helper"],
    "fixed_range" => node["nova"]["networks"][0]["ipv4_cidr"],
    "public_interface" => node["nova"]["network"]["public_interface"],
    "vlan_interface" => node["nova"]["network"]["vlan_interface"],
    "vlan_start" => node["nova"]["network"]["vlan_start"],
    "network_manager" => node["nova"]["network"]["network_manager"],
    "multi_host" => node["nova"]["network"]["multi_host"],
    "firewall_driver" => node["nova"]["network"]["firewall_driver"],
    "scheduler_driver" => node["nova"]["scheduler"]["scheduler_driver"],
    "scheduler_default_filters" => platform_options["nova_scheduler_default_filters"].join(","),
    "scheduler_least_cost_functions" => node["nova"]["scheduler"]["least_cost_functions"],
    "availability_zone" => node["nova"]["config"]["availability_zone"],
    "default_schedule_zone" => node["nova"]["config"]["default_schedule_zone"],
    "virt_type" => node["nova"]["libvirt"]["virt_type"],
    "remove_unused_base_images" => node["nova"]["libvirt"]["remove_unused_base_images"],
    "remove_unused_resized_minimum_age_seconds" => node["nova"]["libvirt"]["remove_unused_resized_minimum_age_seconds"],
    "remove_unused_original_minimum_age_seconds" => node["nova"]["libvirt"]["remove_unused_original_minimum_age_seconds"],
    "checksum_base_images" => node["nova"]["libvirt"]["checksum_base_images"],
    "libvirt_inject_key" => node["nova"]["libvirt"]["libvirt_inject_key"],
    "force_dhcp_release" => node["nova"]["network"]["force_dhcp_release"],
    "send_arp_for_ha" => node["nova"]["network"]["send_arp_for_ha"],
    "auto_assign_floating_ip" => node["nova"]["network"]["auto_assign_floating_ip"],
    "force_raw_images" => node["nova"]["config"]["force_raw_images"],
    "dmz_cidr" => node["nova"]["network"]["dmz_cidr"],
    "allow_same_net_traffic" => node["nova"]["config"]["allow_same_net_traffic"],
    "osapi_max_limit" => node["nova"]["config"]["osapi_max_limit"],
    "cpu_allocation_ratio" => node["nova"]["config"]["cpu_allocation_ratio"],
    "ram_allocation_ratio" => node["nova"]["config"]["ram_allocation_ratio"],
    "snapshot_image_format" => node["nova"]["config"]["snapshot_image_format"],
    "start_guests_on_host_boot" => node["nova"]["config"]["start_guests_on_host_boot"],
    "resume_guests_state_on_host_boot" => node["nova"]["config"]["resume_guests_state_on_host_boot"],
    "quota_security_groups" => node["nova"]["config"]["quota_security_groups"],
    "quota_security_group_rules" => node["nova"]["config"]["quota_security_group_rules"],
    "dhcp_domain" => node["nova"]["network"]["dhcp_domain"],
    "use_single_default_gateway" => node["nova"]["config"]["use_single_default_gateway"],
    "scheduler_max_attempts" => node["nova"]["config"]["scheduler_max_attempts"],
    "quantum_username" => node["quantum"]["service_user"],
    "quantum_password" => node["quantum"]["service_pass"],
    "quantum_tenant" => node["quantum"]["service_tenant_name"],
    "quantum_server_url" => quantum_info["host"],
    "quantum_server_port" => quantum_info["port"]
  )
#  ["nova", "python-novaclient"].each do |com|
#    notifies :run, resources(:execute => "sh #{com}.sh"), :immediately
#    notifies :run, resources(:execute => "patch #{com}.patch"), :immediately
#  end
end
