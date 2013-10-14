name              "make"
description       "Installs make and gcc-c++"
version           "1.0.0"

recipe "default","Installs make and gcc-c++"

%w{ redhat centos fedora ubuntu debian arch scientific }.each do |os|
  supports os
end
