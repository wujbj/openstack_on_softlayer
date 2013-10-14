maintainer       "IBM"
maintainer_email "zhiwchen@cn.ibm.com"
license          "All rights reserved"
description      "Installs/Configures OpenStack HA components"
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version           "0.0.1"

%w{ centos ubuntu }.each do |os|
  supports os
end

%w{ haproxy keepalived stingray nova osops-utils }.each do |dep|
  depends dep
end
