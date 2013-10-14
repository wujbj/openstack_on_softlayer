
# Cookbook Name:: nova
# Recipe:: sccm

################################################################################
# Licensed Materials - Property of IBM Copyright IBM Corporation 2013. All Rights Reserved.
# U.S. Government Users Restricted Rights - Use, duplication or disclosure restricted by GSA ADP
# Schedule Contract with IBM Corp.
################################################################################

# Enable notifications required for SmartCloud Cost Management metering

#include_recipe "nova::nova-common"

params = { 'instance_usage_audit' => 'True', 
		'notification_driver' => 'nova.openstack.common.notifier.rabbit_notifier',
		'monkey_patch_modules' => 'nova.api.ec2.cloud:nova.notifier.api.notify_decorator,nova.compute.api:nova.notifier.api.notify_decorator',
		'notify_on_state_change' => 'vm_and_task_state',
		'default_notification_level' => 'INFO',
		'default_publisher_id' => '$host',
		'notification_topics' => 'notifications',
		'rabbit_host' => 'localhost',
		'rabbit_password' => 'guest',
		'rabbit_virtual_host' => 'test',
		'instance_usage_audit_period' => 'hour',
		'periodic_interval' => '60',
		'periodic_fuzzy_delay' => '60',
		'notification_driver' => ' nova.openstack.common.notifier.rabbit_notifier'
	}

if not node['package_component'].nil?
  release = node['package_component']
else
  release = "essex-final"
end

# We don't seem to have a definition for the objectstore service name in the default list
node.set_unless["nova"]["platform"][release]["nova_objectstore_service"] = "openstack-nova-objectstore"
platform_options = node["nova"]["platform"][release]
	
params.each do |key, value|
	execute "#{key}" do
		command "openstack-config --set /etc/nova/nova.conf DEFAULT #{key} #{value}"
		action :run
		#notifies :create, resources(:template => "/etc/nova/nova.conf"), :delayed
	end
end

%w{api_os_compute_service nova_objectstore_service nova_compute_service nova_network_service nova_scheduler_service nova_cert_service}.each do |service|
	service "#{service}" do
		service_name platform_options["#{service}"]
		supports :restart => true
		action :restart
	end
end
