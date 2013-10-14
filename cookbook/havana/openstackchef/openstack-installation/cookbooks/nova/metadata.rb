maintainer        "Rackspace US, Inc."
license           "Apache 2.0"
description       "Installs and configures Openstack"
long_description  IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version           "1.0.15"
recipe		  "api-ec2", ""
recipe		  "api-metadata", ""
recipe		  "api-os-compute", ""
recipe		  "api-os-volume", ""
recipe		  "compute", ""
recipe		  "default", ""
recipe		  "libvirt", ""
recipe		  "network", ""
recipe		  "nova-common", ""
recipe		  "nova-rsyslog", ""
recipe		  "nova-scheduler-patch", ""
recipe		  "nova-setup", ""
recipe		  "scheduler", ""
recipe		  "vncproxy", ""
recipe		  "volume", ""
recipe		  "sccm", ""

%w{ ubuntu fedora redhat centos }.each do |os|
  supports os
end

%w{ glance keystone quantum openstack-ops-database openstack-ops-messaging openstack-common selinux osops-utils sysctl openstack-patch iptables }.each do |dep|
  depends dep
end
