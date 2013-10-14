if node['openstack']['db']['cluster']
    default['keystone']['depends'] = ['os-ops-database-cluster']
else
    default['keystone']['depends'] = ['os-ops-database']
end

default['keystone_ha'] = false
