#
# Cookbook Name:: keystone
# Recipe:: rcfile
#

secure_admin_password = get_passwords("keystone-admin_user-password")
if secure_admin_password.nil?
  secure_admin_password = node["keystone"]["users"][node["keystone"]["admin_user"]]["password"]
end

ks_admin_endpoint = get_access_endpoint("keystone", "keystone", "admin-api", "endpoint")
node.set["keystone"]["adminURL"] = ks_admin_endpoint["uri"]

template "/root/keystonerc" do
  cookbook "keystone"
  source "keystonerc.erb"
  owner "root"
  group "root"
  mode "0644"

  variables(
     :passwd => secure_admin_password
  )
end
