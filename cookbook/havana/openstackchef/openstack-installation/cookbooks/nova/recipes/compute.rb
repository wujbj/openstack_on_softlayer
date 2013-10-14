#
# Cookbook Name:: nova
# Recipe:: compute
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

nova_compute_packages =
  platform_options["nova_compute_packages"].each.collect { |x| x }

if platform?(%w(ubuntu))
  case node["nova"]["libvirt"]["virt_type"]
  when "kvm"
    nova_compute_packages.push("nova-compute-kvm")
  when "qemu"
    nova_compute_packages.push("nova-compute-qemu")
  end
end



package "qemu-kvm" do
  action :install
  retries 5
  retry_delay 10
end

nova_compute_packages.each do |pkg|
  package pkg do
    action :upgrade
    retries 5
    retry_delay 10
    options platform_options["package_overrides"]
  end
end

if platform?(%w( fedora redhat centos ))
  Chef::Log.info("Processing multipathd and iscsid services.")
  template "/etc/multipath.conf" do
    source "multipath.conf.erb"
    owner "root"
    group "root"
    mode "0600"
  end

  service "multipathd" do
    service_name platform_options["multipath_service"]
    supports :status => true, :restart => true
    action :enable
  end

  service "multipathd" do
    ignore_failure true
    action :start
  end

  execute "create /etc/iscsi/initiatorname.iscsi" do
    command "echo \"InitiatorName=$(iscsi-iname)-$(hostname)\" > /etc/iscsi/initiatorname.iscsi"
    ignore_failure true
    action :run
  end

  template "/etc/iscsi/iscsid.conf" do
    source "iscsid.conf.erb"
    owner "root"
    group "root"
    mode "0600"
  end

  service "iscsid" do
    service_name platform_options["iscsid_service"]
    supports :status => true, "force-start" => true
    action :enable
  end

  execute "iscsid force-start" do
    command "service iscsid force-start"
    ignore_failure true
    action :run
  end
end


cookbook_file "/etc/nova/nova-compute.conf" do
  source "nova-compute.conf"
  mode "0644"
  action :create
end

directory "/var/lib/nova/.ssh" do
  action :create
  #group "nova"
  #owner "nova"
  mode "0700"
end

execute "chown var_lib_nova_ssh_compute" do
  command "chown -R nova:nova /var/lib/nova/.ssh"
  action :run
end

template "/var/lib/nova/.ssh/config" do
  source "libvirtd-ssh-config"
  owner "nova"
  group "nova"
  mode "0600"
end

service "nova-compute" do
  service_name platform_options["nova_compute_service"]
  supports :status => true, :restart => true
  action :enable
  subscribes :restart, resources(:template => "/etc/nova/nova.conf"), :delayed
end

#monitoring_procmon "nova-compute" do
#  service_name=platform_options["nova_compute_service"]
#  process_name "nova-compute"
#  script_name service_name
#end

#monitoring_metric "nova-compute-proc" do
#  type "proc"
#  proc_name "nova-compute"
#  proc_regex platform_options["nova_compute_service"]
#
#  alarms(:failure_min => 2.0)
#end

include_recipe "nova::libvirt"

#execute "remove vhost-net module" do
#    command "rmmod vhost_net"
#    notifies :restart, "service[nova-compute]"
#    notifies :restart, "service[libvirt-bin]"
#    only_if "lsmod | grep vhost_net"
#end

# Sysctl tunables
sysctl_multi "nova" do
  instructions "net.ipv4.ip_forward" => "1"
end
