#
# Cookbook Name:: openstack-cluster
# Recipe:: haproxy-endpoints
#

node['openstack']['endpoints'].each do |name, info|
  if info['cluster']

    include_recipe "haproxy::install"
    haproxy_virtual_server "#{name}" do
      lb_algo "roundrobin"
      mode "http"
      options ["forwardfor", "httpchk", "httplog"]
      vs_listen_ip '0.0.0.0'
      vs_listen_port info['port']
      real_servers info['nodes']
    end

    vip = info['host']
    vip_if = info['host_if']
    ## Keepalived install and configure
    ##==============================
    include_recipe "keepalived::install"
    vi_name = "vi_#{vip.gsub(/\./, '_')}"

    router_id = vip.split(".")[3]
    keepalived_chkscript "chk_haproxy_status" do
        script "/sbin/service haproxy status"
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

        track_script 'chk_haproxy_status'

        notify_master "/sbin/service haproxy restart ;  "
        notify_backup "/sbin/service haproxy restart ; "
        notify_fault "/sbin/service haproxy restart ; "
        action :create
    end

  end
end
