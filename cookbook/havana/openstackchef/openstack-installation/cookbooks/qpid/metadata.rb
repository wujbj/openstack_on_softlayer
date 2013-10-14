name             "qpid"
maintainer       "IBM Corporation"
maintainer_email "zhiwchen@cn.ibm.com"
license          "All rights reserved"
description      "Installs/Configures qpid"
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          "0.0.1"

recipe           "qpid::single", "Install qpid single node"
recipe           "qpid::active", "Install qpid HA active node"
recipe           "qpid::passive", "Install qpid HA passive node"

%w{ rhel centos }.each do |os|
  supports os
end
