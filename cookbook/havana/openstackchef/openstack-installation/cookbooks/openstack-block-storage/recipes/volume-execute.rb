#
# Cookbook Name:: openstack-block-storage
# Recipe:: volume
#
# Copyright 2012, Rackspace US, Inc.
# Copyright 2012-2013, AT&T Services, Inc.
# Copyright 2013, Opscode, Inc.
# Copyright 2013, SUSE Linux Gmbh.
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

device="/dev/vdb"
volume_name="cinder-volumes"

execute "create pv" do
  command "if ! pvdisplay -C #{device};then pvcreate #{device};fi; \
    if ! vgdisplay -C #{volume_name};then vgcreate #{volume_name} #{device};fi"
end
