########################################################################
# Toggles - These can be overridden at the environment level
default[:enable_monit] = false  # OS provides packages                     # cluster_attribute
default[:developer_mode] = false  # we want secure passwords by default    # cluster_attribute
########################################################################

default[:quantum][:db][:name] = "ovs_quantum"				   # node_attribute
default[:quantum][:db][:username] = "quantum"				   # node_attribute
default[:quantum][:db][:password] = "password"				   # node_attribute

default[:quantum][:service_tenant_name] = "service"			   # node_attribute
default[:quantum][:service_user] = "quantum"				   # node_attribute
default[:quantum][:service_role] = "admin"				   # node_attribute
default[:quantum][:service_pass] = "password"				   # fix required

default[:quantum][:services][:server][:scheme] = "http"			   # node_attribute
default[:quantum][:services][:server][:network] = "public"		   	   # node_attribute
default[:quantum][:services][:server][:port] = 9696			   # node_attribute
default[:quantum][:services][:server][:path] = "/"		   		   # node_attribute

default[:quantum][:services]["internal-api"][:scheme] = "http"                    # node_attribute
default[:quantum][:services]["internal-api"][:network] = "management"                           # node_attribute
default[:quantum][:services]["internal-api"][:port] = 9696                        # node_attribute
default[:quantum][:services]["internal-api"][:path] = "/"                                 # node_attribute

default[:quantum][:services]["admin-api"][:scheme] = "http"                    # node_attribute
default[:quantum][:services]["admin-api"][:network] = "management"                           # node_attribute
default[:quantum][:services]["admin-api"][:port] = 9696                        # node_attribute
default[:quantum][:services]["admin-api"][:path] = "/"                                 # node_attribute


default[:quantum][:syslog][:use] = true					   # node_attribute
default[:quantum][:syslog][:facility] = "LOG_LOCAL1"			   # node_attribute
default[:quantum][:syslog][:config_facility] = "local1"			   # node_attribute

default[:quantum][:use_namespaces] = "False"			   	   # node_attribute
default[:quantum][:interface_driver] = "quantum.agent.linux.interface.OVSInterfaceDriver"  # node_attribute
default[:quantum][:use_rootwrap] = "True"	 			   # node_attribute
default[:quantum][:allow_overlapping_ips] = "False"		   	   # node_attribute
default[:quantum][:dnsmasq_dns_server] = ""             # node_attribute
default[:quantum][:dhcp_domain] = "openstacklocal"             # node_attribute
default[:quantum][:quota_port] = 50                     # node_attribute
  

default[:quantum][:plugin] = "openvswitch"				   
default[:quantum][:openvswitch][:enable_tunneling] = "False"
default[:quantum][:openvswitch][:enable_tenant_tunnel] = "False"
default[:quantum][:openvswitch][:tenant_network_type] = "vlan"
default[:quantum][:openvswitch][:network_vlan_range] = "530:550"
default[:quantum][:openvswitch][:tunnel_id_range] = "1:1000"
default[:quantum][:openvswitch][:bridge_mapping_nic] = "eth2"
default[:quantum][:openvswitch][:vm_bridge] = "br-vmnet"
default[:quantum][:openvswitch][:integration_bridge] = "br-int"      # Don't change without a good reason..
default[:quantum][:openvswitch][:tunnel_bridge] = "br-tun"           # only used if tunnel_ranges is set

#default[:quantum][:plugin] = "linuxbridge"				   
default[:quantum][:linuxbridge][:tenant_network_type] = "vlan"
default[:quantum][:linuxbridge][:physical_device_reference] = "physnet1:"
default[:quantum][:linuxbridge][:network_vlan_range] = "901:910"
default[:quantum][:linuxbridge][:mapping_if] = "eth1"

default[:quantum][:floating_if] = "eth2.521"
default[:quantum][:openvswitch][:url] = "http://172.16.0.5/openstack-grizzly-GA/openvswitch"

case platform
when "fedora", "redhat", "centos"
  default[:quantum][:platform] = {
    "quantum_server_packages" => ["openstack-utils", "python-quantumclient", "openstack-quantum", "openstack-quantum-openvswitch", "gedit", "tunctl"],
    "quantum_server_services" => ["quantum-server"],
    "quantum_ovs_agent_packages" => ["openstack-quantum-openvswitch", "gedit", "tunctl"],
    "quantum_ovs_agent_services" => ["quantum-openvswitch-agent"],
    "quantum_lb_agent_packages" => ["openstack-quantum-linuxbridge", "python-quantum", "tunctl", "python-netaddr", "python-qpid"],
    "quantum_lb_agent_services" => ["quantum-linuxbridge-agent"],
    "quantum_dhcp_agent_packages" => ["openstack-quantum", "dnsmasq"],
    "quantum_dhcp_agent_services" => ["quantum-dhcp-agent"],
    "quantum_l3_agent_packages" => ["openstack-quantum"],
    "quantum_l3_agent_services" => ["quantum-l3-agent"],
    "package_overrides" => "",
  }
when "ubuntu"
  default[:quantum][:platform] = {
    "quantum_server_packages" => ["quantum-common", "quantum-server", "quantum-plugin-openvswitch", "python-quantumclient", "python-quantum", "python-mysqldb"],
    "quantum_server_services" => ["quantum-server"],
    "quantum_ovs_agent_packages" => ["openvswitch-datapath-dkms", "quantum-plugin-openvswitch", "quantum-plugin-openvswitch-agent", "python-mysqldb"],
    "quantum_ovs_agent_services" => ["quantum-plugin-openvswitch-agent"],
    "quantum_dhcp_agent_packages" => ["dnsmasq-base", "dnsmasq-utils",
      "libnetfilter-conntrack3", "quantum-dhcp-agent", "python-mysqldb"],
    "quantum_dhcp_agent_services" => ["quantum-dhcp-agent"],
    "quantum_l3_agent_packages" => ["quantum-l3-agent", "python-mysqldb"],
    "quantum_l3_agent_services" => ["quantum-l3-agent"],
    "package_overrides" => ""
  }
end
