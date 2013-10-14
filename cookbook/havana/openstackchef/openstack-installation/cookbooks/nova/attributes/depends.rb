if node['keystone_ha']
    if node['openstack']['mq']['cluster']
        if node['network_type'] == "nova-network"
	  default['nova_api']['depends'] = ['os-ops-messaging-cluster', 'keystone-ha']
          default['nova_conductor']['depends'] = ['os-ops-messaging-cluster', 'keystone-ha']
          default['nova_scheduler']['depends'] = ['os-ops-messaging-cluster', 'keystone-ha']
        else
          if node['quantum_server_ha']
            default['nova_api']['depends'] = ['os-ops-messaging-cluster', 'keystone-ha', 'quantum-server-ha']
            default['nova_conductor']['depends'] = ['os-ops-messaging-cluster', 'keystone-ha', 'quantum-server-ha']
            default['nova_scheduler']['depends'] = ['os-ops-messaging-cluster', 'keystone-ha', 'quantum-server-ha']
          else
            default['nova_api']['depends'] = ['os-ops-messaging-cluster', 'keystone-ha', 'quantum-server']
            default['nova_conductor']['depends'] = ['os-ops-messaging-cluster', 'keystone-ha', 'quantum-server']
            default['nova_scheduler']['depends'] = ['os-ops-messaging-cluster', 'keystone-ha', 'quantum-server']
          end
        end
    else
        if node['network_type'] == "nova-network"
          default['nova_api']['depends'] = ['os-ops-messaging', 'keystone-ha']
          default['nova_conductor']['depends'] = ['os-ops-messaging', 'keystone-ha']
          default['nova_scheduler']['depends'] = ['os-ops-messaging', 'keystone-ha']
        else
          if node['quantum_server_ha']
            default['nova_api']['depends'] = ['os-ops-messaging', 'keystone-ha', 'quantum-server-ha']
            default['nova_conductor']['depends'] = ['os-ops-messaging', 'keystone-ha', 'quantum-server-ha']
            default['nova_scheduler']['depends'] = ['os-ops-messaging', 'keystone-ha', 'quantum-server-ha']
          else
            default['nova_api']['depends'] = ['os-ops-messaging', 'keystone-ha', 'quantum-server']
            default['nova_conductor']['depends'] = ['os-ops-messaging', 'keystone-ha', 'quantum-server']
            default['nova_scheduler']['depends'] = ['os-ops-messaging', 'keystone-ha', 'quantum-server']
          end
        end
    end
else
    if node['openstack']['mq']['cluster']
      if node['network_type'] == "nova-network"
          default['nova_api']['depends'] = ['os-ops-messaging-cluster', 'keystone']
          default['nova_conductor']['depends'] = ['os-ops-messaging-cluster', 'keystone']
          default['nova_scheduler']['depends'] = ['os-ops-messaging-cluster', 'keystone']
      else
        if node['quantum_server_ha']
            default['nova_api']['depends'] = ['os-ops-messaging-cluster', 'keystone', 'quantum-server-ha']
            default['nova_conductor']['depends'] = ['os-ops-messaging-cluster', 'keystone', 'quantum-server-ha']
            default['nova_scheduler']['depends'] = ['os-ops-messaging-cluster', 'keystone', 'quantum-server-ha']
        else
            default['nova_api']['depends'] = ['os-ops-messaging-cluster', 'keystone', 'quantum-server']
            default['nova_conductor']['depends'] = ['os-ops-messaging-cluster', 'keystone', 'quantum-server']
            default['nova_scheduler']['depends'] = ['os-ops-messaging-cluster', 'keystone', 'quantum-server']
        end
      end
    else
      if node['network_type'] == "nova-network"
          default['nova_api']['depends'] = ['os-ops-messaging', 'keystone']
          default['nova_conductor']['depends'] = ['os-ops-messaging', 'keystone']
          default['nova_scheduler']['depends'] = ['os-ops-messaging', 'keystone']
      else
        if node['quantum_server_ha']
            default['nova_api']['depends'] = ['os-ops-messaging', 'keystone', 'quantum-server-ha']
            default['nova_conductor']['depends'] = ['os-ops-messaging', 'keystone', 'quantum-server-ha']
            default['nova_scheduler']['depends'] = ['os-ops-messaging', 'keystone', 'quantum-server-ha']
        else
            default['nova_api']['depends'] = ['os-ops-messaging', 'keystone', 'quantum-server']
            default['nova_conductor']['depends'] = ['os-ops-messaging', 'keystone', 'quantum-server']
            default['nova_scheduler']['depends'] = ['os-ops-messaging', 'keystone', 'quantum-server']
        end
      end
    end
end

default['nova_api_ha'] = false
default['ec2_api_ha'] = false
