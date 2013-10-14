#
# Cookbook Name:: openssh
# Attributes:: default
#
# Author:: Ernie Brodeur <ebrodeur@ujami.net>
# Copyright 2008-2012, Opscode, Inc.
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
# Attributes are commented out using the default config file values.
# Uncomment the ones you need, or set attributes in a role.
#

default['make']['package_name'] = case node['platform_family']
                                    when "rhel", "fedora"
                                       %w{make gcc-c++ ruby-devel python-crypto}
                                     when "arch"
                                       %w{make gcc-c++ ruby-devel}
                                     when "debian"
                                       %w{make g++ ruby-dev}
                                     else
                                       %w{make gcc-c++ ruby-devel}
                                     end


