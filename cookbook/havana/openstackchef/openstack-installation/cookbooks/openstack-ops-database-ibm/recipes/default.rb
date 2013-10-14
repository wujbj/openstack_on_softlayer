#
# Cookbook Name:: openstack-ops-database-ibm
# Recipe:: default
#
# Copyright 2013, IBM
#
# All rights reserved - Do Not Redistribute
#

if node["iptables"]["enabled"] == true
  if node["openstack"]["db"]["service_type"] == "mysql"
    iptables_rule "port_mysql"
  else 
    if node["openstack"]["db"]["service_type"] == "db2"
      iptables_rule "port_db2"
      if node["openstack"]["db"]["cluster"] 
        iptables_rule "port_ha_primary"
      end
    end
  end
end
