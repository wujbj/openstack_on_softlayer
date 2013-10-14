#
# Cookbook Name:: openstack-ha
# Recipe:: join-cluster
#
# Copyright 2013, IBM.
#

if node['ha_type'] == 'haproxy'
    include_recipe "keepalived::install"
    include_recipe "haproxy::install"
    if node['keystone_ha']
        include_recipe "openstack-ha::keystone"
    end
    if node['glance_ha']
        include_recipe "openstack-ha::glance"
    end
    if node['cinder_api_ha']
        include_recipe "openstack-ha::cinder-api"
    end
    if node['nova_api_ha']
        include_recipe "openstack-ha::nova-api"
    end
    if node['ec2_api_ha']
        include_recipe "openstack-ha::ec2-api"
    end
    if node['quantum_server_ha']
        include_recipe "openstack-ha::quantum-server"
    end
elsif node['ha_type'] == 'stingray'
    include_recipe "stingray::join_cluster"
end

if node['iptables']['enabled']
    if node['keystone_ha']
        iptables_rule "port_keystone"
    end
    if node['glance_ha']
        iptables_rule "port_glanceapi"
        iptables_rule "port_glanceregistry"
    end
    if node['cinder_api_ha']
        iptables_rule "port_cinderapi"
    end
    if node['nova_api_ha']
        iptables_rule "port_novaapi"
    end
    if node['ec2_api_ha']
        iptables_rule "port_novaec2api"
    end
    if node['quantum_server_ha']
        iptables_rule "port_quantumserver"
    end
end
