name             "cinder"
maintainer       "Rackspace US, Inc."
license          "Apache 2.0"
description      "Installs/Configures cinder"
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          "0.0.10"
recipe           "cinder-api", ""
recipe           "cinder-scheduler", ""
recipe           "cinder-volume", ""

%w{ centos ubuntu }.each do |os|
  supports os
end

%w{ openstack-common openstack-ops-messaging openstack-ops-database keystone selinux osops-utils openstack-patch iptables }.each do |dep|
  depends dep
end
