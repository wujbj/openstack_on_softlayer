#
# Cookbook Name:: cinder
# Recipe:: cinder-setup
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

secure_password="password"
# Allow for using a well known db password
if node["developer_mode"]
  node.set_unless["cinder"]["db"]["password"] = "cinder"
else
  node.set_unless["cinder"]["db"]["password"] = secure_password
end

# Set a secure keystone service password
node.set_unless['cinder']['service_pass'] = secure_password

platform_options = node["cinder"]["platform"]

ks_admin_endpoint = get_access_endpoint("keystone", "keystone", "admin-api", "endpoint")
keystone = get_settings_by_role("keystone", "keystone")

if volume_endpoint = get_bind_endpoint("cinder", "api")
  admin_volume_endpoint = get_bind_endpoint("cinder", "admin-api")
  internal_volume_endpoint = get_bind_endpoint("cinder", "internal-api")
  Chef::Log.debug("cinder::cinder-setup got cinder endpoint info from cinder-all role holder using get_access_endpoint")
elsif volume_endpoint = get_bind_endpoint("nova", "volume")
  admin_volume_endpoint = volume_endpoint
  internal_volume_endpoint = volume_endpoint
  Chef::Log.debug("cinder::cinder-setup got cinder endpoint info from nova-volume role holder using get_access_endpoint")
end

Chef::Log.debug("volume_endpoint contains: #{volume_endpoint}")

#creates cinder db and user
if node["openstack"]["db"]["service_type"] == "mysql"
  puts 'install mysql python driver'
elsif node["openstack"]["db"]["service_type"] == "db2"
  include_recipe "db2::odbc_install"
end

# install packages for cinder-api
platform_options["cinder_api_packages"].each do |pkg|
  package pkg do
    action node["osops"]["do_package_upgrades"] == true ? :upgrade : :install
    options platform_options["package_overrides"]
  end
end

include_recipe "cinder::cinder-common"

execute "cinder-manage db sync" do
  user "cinder"
  group "cinder"
  command "cinder-manage db sync"
  action :nothing
  subscribes :run, "template[/etc/cinder/cinder.conf]", :immediately
end
