maintainer       "IBM"
maintainer_email "@ibm.com"
license          "Apache 2.0"
description      "Library for bunch of commong stuff including databags"
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          "1.0.0"

%w{ ubuntu fedora redhat centos }.each do |os|
  supports os
end

#%w{ apt yum }.each do |dep|
%w{ yum }.each do |dep|
  depends dep
end
