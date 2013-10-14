#
# Cookbook Name:: openstack-ops-messaging
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

default["openstack"]["mq"]["bind_interface"] = "lo"
default["openstack"]["mq"]["cluster"] = false
default["openstack"]["mq"]["service_type"] = "qpid"

if node["openstack"]["mq"]["cluster"]
  default["openstack"]["mq"]["vip"] = "172.16.1.245"
  default["openstack"]["mq"]["vip_if"] = "eth2"
  default["openstack"]["mq"]["cluster_nodes"] = ['172.16.1.237', '172.16.1.238']
end

default['mq']['services']['mq'] = {
    'network' => 'nova',
    'port' => node['qpid']['broker']['port']
}
