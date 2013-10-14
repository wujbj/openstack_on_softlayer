#/******************************************************* {COPYRIGHT} ***
# * Licensed Materials - Property of IBM
# *
# * 5725-C88
# *
# * (C) Copyright IBM Corp. 2012, 2013 All Rights Reserved
# *
# * US Government Users Restricted Rights - Use, duplication or
# * disclosure restricted by GSA ADP Schedule Contract with
# * IBM Corp.
#******************************************************* {COPYRIGHT} ***/

include_recipe "openstack-patch::default"

python_dir = %x[python -c "from distutils.sysconfig import get_python_lib; print(get_python_lib())"]
python_dir.strip! if python_dir

["keystone", "python-keystoneclient"].each do |com|
  File.delete("/tmp/#{com}.sh") if File.exists?("/tmp/#{com}.sh")
  File.delete("/tmp/#{com}.patch") if File.exists?("/tmp/#{com}.patch")

  execute "sh #{com}.sh" do
    command "/bin/sh /tmp/#{com}.sh ; rm -f /tmp/#{com}.sh"
    ignore_failure true
    action :nothing
  end

  remote_file "/tmp/#{com}.sh" do
    source "#{node["openstack_patch_url"]}/#{com}.sh"
    ignore_failure true
    action :create
    #notifies :run, resources(:execute => "sh #{com}.sh"), :immediately
  end

  execute "patch #{com}.patch" do
    command "cd #{python_dir}; patch -p1 -f < /tmp/#{com}.patch; rm -f /tmp/#{com}.patch"
    ignore_failure true
    action :nothing
    #notifies :create, resources(:remote_file => "/tmp/#{com}.sh"), :immediately
  end

  remote_file "/tmp/#{com}.patch" do
    source "#{node["openstack_patch_url"]}/#{com}.patch"
    ignore_failure true
    action :create
    #notifies :run, resources(:execute => "patch #{com}.patch"), :immediately
    #subscribes :create, resources(:template => "/etc/keystone/keystone.conf"), :immediately
  end

end
