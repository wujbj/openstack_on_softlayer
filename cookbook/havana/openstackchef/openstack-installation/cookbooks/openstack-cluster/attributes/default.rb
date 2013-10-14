default['openstack']['ha']['service_type'] = 'haproxy'

default['openstack']['endpoints']['identity-api']['cluster'] = false
default['openstack']['endpoints']['identity-api']['host_if'] = 'eth0'
default['openstack']['endpoints']['identity-api']['nodes'] = ['127.0.0.1', '127.0.0.2']

default['openstack']['endpoints']['identity-admin']['cluster'] = false
default['openstack']['endpoints']['identity-admin']['host_if'] = 'eth0'
default['openstack']['endpoints']['identity-admin']['nodes'] = ['127.0.0.1', '127.0.0.2']

default['openstack']['endpoints']['image-api']['cluster'] = false
default['openstack']['endpoints']['image-api']['host_if'] = 'eth0'
default['openstack']['endpoints']['image-api']['nodes'] = ['127.0.0.1', '127.0.0.2']

default['openstack']['endpoints']['image-registry']['cluster'] = false
default['openstack']['endpoints']['image-registry']['host_if'] = 'eth0'
default['openstack']['endpoints']['image-registry']['nodes'] = ['127.0.0.1', '127.0.0.2']

default['openstack']['endpoints']['volume-api']['cluster'] = false
default['openstack']['endpoints']['volume-api']['nodes'] = ['127.0.0.1', '127.0.0.2']

default['openstack']['endpoints']['compute-api']['cluster'] = false
default['openstack']['endpoints']['compute-api']['host_if'] = 'eth0'
default['openstack']['endpoints']['compute-api']['nodes'] = ['127.0.0.1', '127.0.0.2']

default['openstack']['endpoints']['compute-ec2-api']['cluster'] = false
default['openstack']['endpoints']['compute-ec2-api']['host_if'] = 'eth0'
default['openstack']['endpoints']['compute-ec2-api']['nodes'] = ['127.0.0.1', '127.0.0.2']

default['openstack']['endpoints']['compute-ec2-admin']['cluster'] = false
default['openstack']['endpoints']['compute-ec2-admin']['host_if'] = 'eth0'
default['openstack']['endpoints']['compute-ec2-admin']['nodes'] = ['127.0.0.1', '127.0.0.2']

default['openstack']['endpoints']['compute-xvpvnc']['cluster'] = false
default['openstack']['endpoints']['compute-xvpvnc']['host_if'] = 'eth0'
default['openstack']['endpoints']['compute-xvpvnc']['nodes'] = ['127.0.0.1', '127.0.0.2']

default['openstack']['endpoints']['compute-novnc']['cluster'] = false
default['openstack']['endpoints']['compute-novnc']['host_if'] = 'eth0'
default['openstack']['endpoints']['compute-novnc']['nodes'] = ['127.0.0.1', '127.0.0.2']

default['openstack']['endpoints']['network-api']['cluster'] = false
default['openstack']['endpoints']['network-api']['nodes'] = ['127.0.0.1', '127.0.0.2']

default['openstack']['endpoints']['metering-api']['cluster'] = false
default['openstack']['endpoints']['metering-api']['nodes'] = ['127.0.0.1', '127.0.0.2']
