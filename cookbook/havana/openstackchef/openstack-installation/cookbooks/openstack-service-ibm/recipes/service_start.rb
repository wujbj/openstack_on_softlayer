#
# Cookbook Name:: openstack-service-ibm
# Recipe:: service_start
#
# Copyright 2013, IBM , bhdai@cn.ibm.com
#
# All rights reserved - Do Not Redistribute
#


service_block = Hash.new
service_block_array = Array.new

if ::File.exist?("/tmp/role-service")
  file = ::File.open("/tmp/role-service","r")
  i = 0
  while(lines = file.gets)
    a = lines.split(",")
    service_block = { :service => a[0], :blockname => a[1]  }
    service_block_array[i] = service_block
    #puts "service = #{service_block_array[i][:service]}, block = #{service_block_array[i][:blockname]}"
    i = i + 1
  end
  file.close
else
  puts "The file /tmp/role-service do not exist.exit now."
  exit 1
end

#        node.from_file(run_context.resolve_attribute(service_and_block[:blockname], "default.rb"))

=begin
ruby_block "stop_service" do
  block do
  end
  action :create
end
=end

execute "remove_the_exist_service_name_file" do
  command " rm -rf /tmp/exact-service-name"
  ignore_failure true
  action :run
  only_if "test -f /tmp/exact-service-name"
end

service_block_array.each do |service_and_block|
  puts "service = #{service_and_block[:service]}, block = #{service_and_block[:blockname]}"
  l_blockname = service_and_block[:blockname].lstrip
  only_blockname = l_blockname.rstrip
  #case service_and_block[:blockname]
  case only_blockname
    when 'openstack-block-storage'
      begin
        platform_options = node["openstack"]["block-storage"]["platform"]
        servicename = platform_options[service_and_block[:service]]
        execute "service-#{servicename}-start" do
          command "echo #{servicename} >> /tmp/exact-service-name"
          ignore_failure true
          action :run
        end
      end
    when 'openstack-compute'
      begin
        platform_options = node["openstack"]["compute"]["platform"]
        servicename = platform_options[service_and_block[:service]]
        execute "service-#{servicename}-start" do
          command "echo #{servicename} >> /tmp/exact-service-name"
          ignore_failure true
          action :run
        end
      end
    when 'openstack-identity'
      begin
        platform_options = node["openstack"]["identity"]["platform"]
        servicename = platform_options[service_and_block[:service]]
        execute "service-#{servicename}-start" do
          command "echo #{servicename} >> /tmp/exact-service-name"
          ignore_failure true
          action :run
        end
      end
    when 'openstack-image'
      begin
        platform_options = node["openstack"]["image"]["platform"]
        servicename = platform_options[service_and_block[:service]]
        execute "service-#{servicename}-start" do
          command "echo #{servicename} >> /tmp/exact-service-name"
          ignore_failure true
          action :run
        end
      end
    when 'openstack-network'
      begin
        platform_options = node["openstack"]["network"]["platform"]
        servicename = platform_options[service_and_block[:service]]
        execute "service-#{servicename}-start" do
          command "echo #{servicename} >> /tmp/exact-service-name"
          ignore_failure true
          action :run
        end
      end
  end
end
