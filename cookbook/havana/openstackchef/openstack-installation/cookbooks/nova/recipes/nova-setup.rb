#
# Cookbook Name:: nova
# Recipe:: nova-setup
#
# Copyright 2012, Rackspace US, Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

#::Chef::Recipe.send(:include, Opscode::OpenSSL::Password)

class ::Chef::Recipe
      include ::Openstack
end

include_recipe "nova::nova-common"

if node["openstack"]["db"]["service_type"] == "mysql"
  ## Install MySQL-python
  node['db']['mysql']['packages'].each do |pkg|
    package "#{pkg}" do
      action :install
      retries 5
      retry_delay 10
    end
  end
elsif node["openstack"]["db"]["service_type"] == "db2"
  include_recipe "db2::odbc_install"
end

#include_recipe "monitoring"
ks_service_endpoint = get_access_endpoint("keystone", "keystone","service-api", "endpoint")
keystone = get_settings_by_role("keystone", "keystone")
keystone_admin_user = keystone["admin_user"]
keystone_admin_password = keystone["users"][keystone_admin_user]["password"]
keystone_admin_tenant = keystone["users"][keystone_admin_user]["default_tenant"]

execute "nova-manage db sync" do
  command "nova-manage db sync"
  action :run
  #not_if "nova-manage db version && test $(nova-manage db version) -gt 0"
end
