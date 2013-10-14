#
# Cookbook Name:: openstack-ops-messaging
# Recipe:: qpid-ha-active
#
# Copyright 2013, IBM
#
# All rights reserved - Do Not Redistribute
#

qpid_ha_setup "setup qpid active" do

    ha_public_url   node['openstack']['mq']['vip']
    ha_brokers_url  node['openstack']['mq']['cluster_nodes']

    action :create

end

vip = node['openstack']['mq']['vip']
vip_if = node['openstack']['mq']['vip_if']
##========================================

include_recipe "keepalived::install"

vi_name = "vi_#{vip.gsub(/\./, '_')}"
router_id = vip.split(".")[3]

keepalived_chkscript "chk_qpid_status" do
    script "/sbin/service qpidd status"
    interval 1
    weight -10
    rise 1
    fall 1
    action :create
end

keepalived_vrrp vi_name do
	state 'BACKUP'
    interface vip_if
    virtual_router_id router_id.to_i
    priority 100
    advert_int 1

    auth_type 'pass'
    auth_pass "^123#{router_id}$"

    virtual_ipaddress Array(vip)

    track_script 'chk_qpid_status'

    notify_master "/usr/bin/qpid-ha promote"
    notify_backup "/sbin/service qpidd restart"
    notify_fault "/sbin/service qpidd restart"
    action :create
end
