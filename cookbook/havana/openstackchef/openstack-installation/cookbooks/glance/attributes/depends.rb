if node['keystone_ha']
    if node['openstack']['mq']['cluster']
        default['glance']['depends'] = ['os-ops-messaging-cluster', 'keystone-ha']
    else
        default['glance']['depends'] = ['os-ops-messaging', 'keystone-ha']
    end
else
    if node['openstack']['mq']['cluster']
        default['glance']['depends'] = ['os-ops-messaging-cluster', 'keystone']
    else
        default['glance']['depends'] = ['os-ops-messaging', 'keystone']
    end
end

default['glance_ha'] = false
