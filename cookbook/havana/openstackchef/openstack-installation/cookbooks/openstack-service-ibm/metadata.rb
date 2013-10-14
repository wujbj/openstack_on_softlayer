name             'openstack-service-ibm'
maintainer       'YOUR_COMPANY_NAME'
maintainer_email 'YOUR_EMAIL'
license          'All rights reserved'
description      'Installs/Configures openstack-service-ibm'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          '1.0.0'

depends "openstack-block-storage"
depends "openstack-compute"
depends "openstack-identity"
depends "openstack-image"
depends "openstack-network"

