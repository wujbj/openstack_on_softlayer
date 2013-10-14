#
# Cookbook Name:: openstack-common
# Recipe:: rcfile
#

class ::Chef::Recipe
  include ::Openstack
end

token = secret "secrets", "openstack_identity_bootstrap_token"
tenant_name = node["openstack"]["identity"]["admin_tenant_name"]
admin_user = node["openstack"]["identity"]["admin_user"]
admin_pass = user_password node["openstack"]["identity"]["admin_user"]
identity_admin_endpoint = endpoint "identity-admin"
auth_uri = ::URI.decode identity_admin_endpoint.to_s

template "/root/keystonerc" do
  cookbook "openstack-common"
  source "keystonerc.erb"
  owner "root"
  group "root"
  mode "0644"

  variables(
    :admin_token => token,
    :admin_user => admin_user,
    :admin_pass => admin_pass,
    :tenant_name => tenant_name,
    :auth_uri => auth_uri
  )
end
