maintainer        "IBM Corporation"
license           "Apache 2.0"
description       "Installs and configures the Keystone Identity Service"
long_description  IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version           "1.0.16"
recipe            "keystone::server", "Installs packages required for a keystone server"

%w{ ubuntu fedora }.each do |os|
  supports os
end

%w{ databag openstack-ops-database openstack-common osops-utils openstack-patch iptables}.each do |dep|
  depends dep
end
