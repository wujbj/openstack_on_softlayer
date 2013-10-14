maintainer        "Rackspace US, Inc."
license           "Apache 2.0"
description       "Makes the rabbitmq cookbook behave correctly with OpenStack"
version           "1.0.9"

%w{ ubuntu fedora }.each do |os|
  supports os
end

%w{ rabbitmq osops-utils sysctl }.each do |dep|
  depends dep
end
