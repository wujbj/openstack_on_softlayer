
class ::Chef::Recipe
    include ::Openstack
end

# Set LinuxBridge specific attribute
node.default[:quantum][:interface_driver] = "quantum.agent.linux.interface.BridgeInterfaceDriver"

if node["db_type"] == "mysql"
  mysql_info = get_access_endpoint("init-db", "mysql", "db")
elsif node["db_type"] == "db2"
  include_recipe "db2::odbc_install"
end


db_user = node["openstack"]["network"]["db"]["username"]
db_pass = db_password "quantum"
db_connection = db_uri("network", db_user, db_pass)

#db_connection = get_db_connection(node["db_type"], node["quantum"]["db"]["name"], node["quantum"]["db"]["username"], node["quantum"]["db"]["password"])

template "/etc/quantum/plugins/linuxbridge/linuxbridge_conf.ini" do
        source "linuxbridge_conf.ini.erb"
        owner "quantum"
        group "quantum"
        mode "0644"
        variables(
#                "db_user" => node['quantum']['db']['username'],
#                "db_password" => node['quantum']['db']['password'],
#                "db_ip_address" => mysql_info['host'], 
#                "db_name" => node['quantum']['db']['name'],
		"db_connection" => db_connection,
                "tenant_network_type" => node['quantum']['linuxbridge']['tenant_network_type'],
                "physical_device_reference" => node['quantum']['linuxbridge']['physical_device_reference'],
                "network_vlan_range" => node['quantum']['linuxbridge']['network_vlan_range'],
		"mapping_if" => node['quantum']['linuxbridge']['mapping_if']	
#		"local_ip" => local_ip
        )
end

service "quantum-server" do
	action :restart
	only_if { node['roles'].include?("quantum-server") } 
end

