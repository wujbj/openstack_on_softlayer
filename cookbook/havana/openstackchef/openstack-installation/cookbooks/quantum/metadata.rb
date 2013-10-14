name		 "quantum"
maintainer       "Tao Tao"
maintainer_email "ttao@us.ibm.com"
license          "Apache 2.0"
description      "Installs/Configures quantum"
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          "0.1.0"

#depends		 "mysql"
#depends		 "osops-utils"
%w{ openstack-ops-messaging openstack-ops-database openstack-common keystone selinux osops-utils nova iptables }.each do |dep|
  depends dep
end
