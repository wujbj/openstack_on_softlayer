maintainer        "IBM, Inc."
license           "Apache 2.0"
description       "Demo Openstack Upgrade"
long_description  IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version           "1.0.0"
recipe		  "compute-upgrade-epel", ""
recipe		  "volume-upgrade-epel", ""

%w{ redhat }.each do |os|
  supports os
end

#%w{ backup uninstall yum install restore }.each do |dep|
%w{ backup uninstall yum install restore }.each do |dep|
  depends dep
end
