#
# Cookbook Name:: openstack-ops-database
# Recipe:: default
#
# Copyright 2013, AT&T Services, Inc.
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

default["openstack"]["db"]["bind_interface"] = "eth0"
default["openstack"]["db"]["service_type"] = "mysql"
default["openstack"]["db"]["cluster"] = false
default["openstack"]["db"]["vip"] = '127.0.0.2'
default["openstack"]["db"]["vip_if"] = 'eth0'
default["openstack"]["db"]["db2_name"] = 'openstac'

if node["openstack"]["db"]["service_type"] == 'db2'
  node.force_override['openstack']['db']['identity']['db_name'] = node["openstack"]["db"]["db2_name"]
  node.force_override['openstack']['db']['image']['db_name'] = node["openstack"]["db"]["db2_name"]
  node.force_override['openstack']['db']['block-storage']['db_name'] = node["openstack"]["db"]["db2_name"]
  node.force_override['openstack']['db']['volume']['db_name'] = node["openstack"]["db"]["db2_name"]
  node.force_override['openstack']['db']['compute']['db_name'] = node["openstack"]["db"]["db2_name"]
  node.force_override['openstack']['db']['network']['db_name'] = node["openstack"]["db"]["db2_name"]
  node.force_override['openstack']['db']['metering']['db_name'] = node["openstack"]["db"]["db2_name"]
  node.force_override['openstack']['db']['dashboard']['db_name'] = node["openstack"]["db"]["db2_name"]

  if node["openstack"]["db"]["cluster"]
    default["openstack"]["db"]["db2_primary_host"] = '127.0.0.3'
    default['openstack']['db']['db2_primary_port'] = 10000
    default['openstack']['db']['db2_standby_host'] = '127.0.0.4'
    default['openstack']['db']['db2_standby_port'] = 10000
  end
end

# Platform defaults
case platform
when "fedora", "redhat", "centos" # :pragma-foodcritic: ~FC024 - won"t fix this
  default["openstack"]["db"]["platform"]["mysql_python_packages"] = [ "MySQL-python" ]
  default["openstack"]["db"]["platform"]["postgresql_python_packages"] = [ "python-psycopg2" ]
  default["openstack"]["db"]["platform"]["db2_python_packages"] = [ "python-ibm-db" ]
when "suse"
  default["openstack"]["db"]["platform"]["mysql_python_packages"] = [ "python-mysql" ]
  default["openstack"]["db"]["platform"]["postgresql_python_packages"] = [ "python-psycopg2" ]
when "ubuntu"
  default["openstack"]["db"]["platform"]["mysql_python_packages"] = [ "python-mysqldb" ]
  default["openstack"]["db"]["platform"]["postgresql_python_packages"] = [ "python-psycopg2" ]
end
