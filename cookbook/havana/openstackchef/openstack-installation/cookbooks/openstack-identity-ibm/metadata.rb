name             'openstack-identity-ibm'
maintainer       'YOUR_COMPANY_NAME'
maintainer_email 'YOUR_EMAIL'
license          'All rights reserved'
description      'Installs/Configures openstack-identity-ibm'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          '0.1.0'
%w{ iptables osops-utils keepalived openstack-identity }.each do |dep|
  depends dep
end
