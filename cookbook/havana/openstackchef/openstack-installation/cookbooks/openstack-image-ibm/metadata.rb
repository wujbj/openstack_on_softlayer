name             'openstack-image-ibm'
maintainer       'YOUR_COMPANY_NAME'
maintainer_email 'YOUR_EMAIL'
license          'All rights reserved'
description      'Installs/Configures openstack-image-ibm'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          '0.1.0'
%w{ iptables osops-utils keepalived openstack-image}.each do |dep|
  depends dep
end