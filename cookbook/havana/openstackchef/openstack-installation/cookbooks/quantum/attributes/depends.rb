if node['keystone_ha']
    if node['openstack']['mq']['cluster']
        default['quantum_server']['depends'] = ['os-ops-messaging-cluster', 'keystone-ha']
    else
        default['quantum_server']['depends'] = ['os-ops-messaging', 'keystone-ha']
    end
else
    if node['openstack']['mq']['cluster']
        default['quantum_server']['depends'] = ['os-ops-messaging-cluster', 'keystone']
    else
        default['quantum_server']['depends'] = ['os-ops-messaging', 'keystone']
    end
end

default['quantum_server_ha'] = false
