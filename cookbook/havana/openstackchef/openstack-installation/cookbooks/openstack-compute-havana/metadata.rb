name             "openstack-compute-havana"
maintainer       "Opscode, Inc."
maintainer_email "matt@opscode.com"
license          "Apache 2.0"
description      "The OpenStack Compute service Nova."
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          "7.0.0"

recipe "openstack-compute-havana::api-ec2", "Installs AWS EC2 compatible API"
recipe "openstack-compute-havana::api-metadata", "Installs the nova metadata package"
recipe "openstack-compute-havana::api-os-compute", "Installs OS API"
recipe "openstack-compute-havana::compute", "nova-compute service"
recipe "openstack-compute-havana::libvirt", "Installs libvirt, used by nova compute for management of the virtual machine environment"
recipe "openstack-compute-havana::identity_registration", "Registers the API and EC2 endpoints with Keystone"
recipe "openstack-compute-havana::network", "Installs nova network service"
recipe "openstack-compute-havana::nova-cert", "Installs nova-cert service"
recipe "openstack-compute-havana::nova-common", "Builds the basic nova.conf config file with details of the rabbitmq, mysql, glance and keystone servers"
recipe "openstack-compute-havana::nova-setup", "Sets up the nova database on the mysql server, including the initial schema and subsequent creation of the appropriate networks"
recipe "openstack-compute-havana::scheduler", "Installs nova scheduler service"
recipe "openstack-compute-havana::vncproxy", "Installs and configures the vncproxy service for console access to VMs"

%w{ ubuntu fedora redhat centos suse }.each do |os|
  supports os
end

depends "openstack-common", "~> 0.4.0"
depends "openstack-identity", "~> 7.0.0"
depends "openstack-image", "~> 7.0.0"
depends "openstack-network-havana", "~> 7.0.0"
depends "selinux"
depends "sysctl"
depends "yum"
depends "python"