name             'openstack-block-storage-ibm'
maintainer       'YOUR_COMPANY_NAME'
maintainer_email 'YOUR_EMAIL'
license          'All rights reserved'
description      'Installs/Configures openstack-block-storage-ibm'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          '0.1.0'

%w{ iptables qpid osops-utils keepalived openstack-block-storage }.each do |dep|
  depends dep
end
