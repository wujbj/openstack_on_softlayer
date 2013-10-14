if node['keystone_ha']
    if node['openstack']['mq']['cluster']
        default['cinder_api']['depends'] = ['os-ops-messaging-cluster', 'keystone-ha']
        default['cinder_scheduler']['depends'] = ['os-ops-messaging-cluster', 'keystone-ha']
    else
        default['cinder_api']['depends'] = ['os-ops-messaging', 'keystone-ha']
        default['cinder_scheduler']['depends'] = ['os-ops-messaging', 'keystone-ha']
    end
else
    if node['openstack']['mq']['cluster']
        default['cinder_api']['depends'] = ['os-ops-messaging-cluster', 'keystone']
        default['cinder_scheduler']['depends'] = ['os-ops-messaging-cluster', 'keystone']
    else
        default['cinder_api']['depends'] = ['os-ops-messaging', 'keystone']
        default['cinder_scheduler']['depends'] = ['os-ops-messaging', 'keystone']
    end
end

default['cinder_api_ha'] = false
