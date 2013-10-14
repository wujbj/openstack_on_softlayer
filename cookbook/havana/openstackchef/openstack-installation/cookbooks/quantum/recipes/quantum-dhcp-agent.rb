#
# Cookbook Name:: quantum
# Recipe:: quantum-dhcp-agent
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

# Install packages and services
platform_options = node['quantum']['platform']

platform_options['quantum_dhcp_agent_packages'].each do |pkg|
  package pkg do
    action :upgrade
    retries 5
    retry_delay 10
    options platform_options['package_overrides']
  end
end

platform_options['quantum_dhcp_agent_services'].each do |svc|
  service svc do
    service_name svc
      supports :status => true, :restart => true
      action :enable
      subscribes :restart, "template[/etc/quantum/quantum.conf]", :delayed
      subscribes :restart, "template[/etc/quantum/dhcp_agent.ini]", :delayed
  end
end

template "/etc/quantum/dhcp_agent.ini" do
        source "dhcp_agent.ini.erb"
        owner "quantum"
        group "quantum"
        mode "0644"
        variables(
                "use_namespaces" => node['quantum']['use_namespaces'],
                "dnsmasq_dns_server" => node['quantum']['dnsmasq_dns_server'],
                "dhcp_domain" => node['quantum']['dhcp_domain'],
		"interface_driver" => node['quantum']['interface_driver']
        )
#      notifies :restart, resources(:service => "quantum-dhcp-agent")
end

if node["iptables"]["enabled"] == true
  iptables_rule "port_quantum"
end
