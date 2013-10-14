name              "openstack-network-havana"
maintainer        "Jay Pipes <jaypipes@gmail.com>"
license           "Apache 2.0"
description       "Installs and configures the OpenStack Network API Service and various agents and plugins"
long_description  IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version           "7.0.0"
recipe            "openstack-network-havana::server", "Installs packages required for a OpenStack Network server"
recipe            "openstack-network-havana::openvswitch", "Installs packages required for OVS"
recipe            "openstack-network-havana::metadata_agent", "Installs packages required for a OpenStack Network Metadata Agent"
recipe            "openstack-network-havana::identity_registration", "Registers OpenStack Network endpoints and service user with Keystone"

%w{ ubuntu fedora redhat centos suse }.each do |os|
  supports os
end

depends           "openstack-identity", "~> 7.0"
depends           "openstack-common", "~> 0.4.0"
depends           "mysql"
depends           "postgresql"
