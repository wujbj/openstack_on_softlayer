#
# Cookbook Name:: nova
# Recipe:: scheduler
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

execute "chown var_lock_nova_conductor" do
  command "chown -R nova:nova /var/lock/nova"
  action :run
end

platform_options["nova_conductor_packages"].each do |pkg|
  package pkg do
    action :upgrade
    options platform_options["package_overrides"]
  end
end

service "nova-conductor" do
  service_name platform_options["nova_conductor_service"]
  supports :status => true, :restart => true
  action [ :enable, :start ]
  subscribes :restart, resources(:template => "/etc/nova/nova.conf"), :delayed
end

#monitoring_procmon "nova-conductor" do
#  service_name=platform_options["nova_conductor_service"]
#  process_name "nova-conductor"
#  script_name service_name
#end

#monitoring_metric "nova-conductor-proc" do
#  type "proc"
#  proc_name "nova-conductor"
#  proc_regex platform_options["nova_conductor_service"]
#
#  alarms(:failure_min => 2.0)
#end


#include_recipe "nova::nova-scheduler-patch"
