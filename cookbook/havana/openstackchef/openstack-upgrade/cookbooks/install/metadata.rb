maintainer        "IBM, Inc."
license           "Apache 2.0"
description       "Openstack Install"
long_description  IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version           "1.0.0"
recipe		  "install-cinder-volume", ""
recipe		  "install-nova-compute", ""
recipe		  "install-nova-controller", ""

%w{ redhat }.each do |os|
  supports os
end

#%w{ yum }.each do |dep|
%w{ yum }.each do |dep|
  depends dep
end
