#
# Cookbook Name:: quantum
# Recipe:: network
#

include_recipe "keystone::rcfile"

package "python-quantumclient" do
    action :install
end

cidr = node['nova']['networks'].first['ipv4_cidr']
if cidr.nil?
    cidr = "10.5.5.0/24"
end

execute "create quantum network" do
    command "source /root/keystonerc && quantum net-create net1 \
        && quantum subnet-create --name=subnet1 net1 #{cidr}"
    not_if "source /root/keystonerc && quantum net-show net1"
end
