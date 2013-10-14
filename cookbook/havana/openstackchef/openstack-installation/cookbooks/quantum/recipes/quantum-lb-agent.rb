
# Install service
platform_options = node['quantum']['platform']

platform_options['quantum_lb_agent_packages'].each do |pkg|
  package pkg do
    action :upgrade
    retries 5
    retry_delay 10
    options platform_options['package_overrides']
  end
end

platform_options['quantum_lb_agent_services'].each do |svc|
        service svc do
                service_name svc
                supports :status => true, :restart => true
                action :enable
        end
end

# Create config file
include_recipe "quantum::_quantum-config"
include_recipe "quantum::_lb-plugin-config"

service "quantum-linuxbridge-agent" do
	action :restart
	only_if { node['roles'].include?("quantum-linuxbridge-agent") }
end

mapping_if = node['quantum']['mapping_if']
# Bring up interface
execute "Bring up interface" do
	command "ip link set #{mapping_if} up; true"
	action :run
end
