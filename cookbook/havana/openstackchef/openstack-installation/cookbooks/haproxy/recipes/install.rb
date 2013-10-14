#
# Cookbook Name:: haproxy
#
# Recipe:: install
#
# Copyright 2013, IBM.
#

secure_password = "password"

platform_options = node["haproxy"]["platform"]

if node["developer_mode"]
  node.set_unless["haproxy"]["admin_password"] = "password"
else
  node.set_unless["haproxy"]["admin_password"] = secure_password
end

platform_options["haproxy_packages"].each do |pkg|
  package pkg do
    action :install
    options platform_options["package_options"]
  end
end

template "/etc/default/haproxy" do
  source "haproxy-default.erb"
  owner "root"
  group "root"
  mode 0644
  only_if { platform?("ubuntu","debian") }
end

directory "/etc/haproxy/haproxy.d" do
  mode 0655
  owner "root"
  group "root"
end

cookbook_file "/etc/init.d/haproxy" do
  if platform?(%w{fedora redhat centos})
    source "haproxy-init-rhel"
  end
  if platform?(%w{ubuntu debian})
   source "haproxy-init-ubuntu"
  end

  mode 0655
  owner "root"
  group "root"
end

service "haproxy" do
  service_name platform_options["haproxy_service"]
  supports :status => true, :restart => true, :reload => true
  action [ :enable ]
  retries 5
  retry_delay 5
end

template "/etc/haproxy/haproxy.cfg" do
  source "haproxy.cfg.erb"
  owner "root"
  group "root"
  mode 0644
  variables(
    "admin_port"     => node["haproxy"]["admin_port"],
    "admin_password" => node["haproxy"]["admin_password"]
  )
  notifies :restart, resources(:service => "haproxy"), :immediately
end
