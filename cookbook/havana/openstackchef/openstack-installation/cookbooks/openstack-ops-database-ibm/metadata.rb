maintainer       "IBM"
maintainer_email "zhiwchen@cn.ibm.com"
license          "All rights reserved"
description      "Installs/Configures SCI specific Messaging"
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          "1.0.0"

%w{ iptables osops-utils }.each do |dep|
  depends dep
end
