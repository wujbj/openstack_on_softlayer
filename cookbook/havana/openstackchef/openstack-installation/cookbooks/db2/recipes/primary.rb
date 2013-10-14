#
# Cookbook Name:: db2
# Recipe:: primary
#
# Copyright 2013, IBM
#
# All rights reserved - Do Not Redistribute
#

db2_primary "setup DB2 primary" do
    db_name      node['db2']['db_name']
    primary_host node['db2']['primary_host']
    primary_port node['db2']['primary_port']
    standby_host node['db2']['standby_host']
    standby_port node['db2']['standby_port']
    action :setup
end

vip = node['db2']['ha_vip']
db_name = node['db2']['db_name']
instance_username = node['db2']['instance_username']

##==================================================

include_recipe "keepalived::install"

Chef::Log.info("Configuring vrrp instance for DB2 HA")

vi_name = "vi_#{vip.gsub(/\./, '_')}"
router_id = vip.split(".")[3]

keepalived_chkscript "chk_db2_status" do
    script "su - #{instance_username} -c 'db2pd -db #{db_name} -hadr'"
    interval 1
    weight -10
    rise 1
    fall 1
    action :create
end

if_for_net = get_if_for_net('nova')

keepalived_vrrp vi_name do
	state 'BACKUP'
    interface if_for_net
    virtual_router_id router_id.to_i  # Needs to be a integer between 0..255
    priority 100
    advert_int 1
  
    auth_type 'pass'
    auth_pass "^123#{router_id}$"
  
    virtual_ipaddress Array(vip)
    #virtual_ipaddress Array("#{vip}/16 brd 172.16.255.255")
  
    track_script 'chk_db2_status'
  
    notify_master "/bin/su - #{instance_username} -c 'db2 takeover hadr on db #{db_name} by force'"
    notify_backup "/bin/su - #{instance_username} -c 'db2 start hadr on db #{db_name} as standby'"
    notify_fault "/bin/echo ok"
    action :create
end
