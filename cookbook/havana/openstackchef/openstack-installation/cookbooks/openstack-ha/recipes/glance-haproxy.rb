#
# Cookbook Name:: openstack-ha
# Recipe:: glance-haproxy
#
# Copyright 2013, IBM.
#

# Include default keepalived recipe
include_recipe "keepalived"

# Include default haproxy recipe, for loadbalancing
include_recipe "haproxy"

ks_admin_endpoint = get_access_endpoint("keystone", "keystone", "admin-api", "endpoint")
keystone = get_settings_by_role("keystone","keystone")
haproxy_platform_options = node["haproxy"]["platform"]

# set up floating ip/load balancer for the defined services
node["ha"]["available_services"]["glance"].each do |s|

  role, ns, svc, svc_type, lb_mode, lb_algo, lb_opts =
    s["role"], s["namespace"], s["service"], s["service_type"],
    s["lb_mode"], s["lb_algorithm"], s["lb_options"]

  Chef::Log.info("Skipping: #{ns}-#{svc}") if ! rcb_safe_deref(node, "vips.#{ns}-#{svc}") || ! rcb_safe_deref(node, "external-vips.#{ns}-#{svc}")

  if rcb_safe_deref(node, "ha.swift-only") && node['ha']['swift-only']
    unless node.run_list.expand(node.chef_environment).roles.include?("ha-controller1")||
           node.run_list.expand(node.chef_environment).roles.include?("ha-controller2")
      next unless ["swift-proxy", "keystone-admin-api", "keystone-service-api"].include?("#{ns}-#{svc}")
    end
  end

  # See if a vip has been defined for this service, if yes create a vrrp and virtual server definition
  if listen_ip = rcb_safe_deref(node, "vips.#{ns}-#{svc}")

    # make sure we have some back ends
    if get_role_count(role) > 0

      # first configure the vrrp
      Chef::Log.info("Configuring vrrp for #{ns}-#{svc}")
      vrrp_name = "vi_#{listen_ip.gsub(/\./, '_')}"
      vrrp_interface = get_if_for_net('nova', node)
      router_id = listen_ip.split(".")[3]

      keepalived_chkscript "haproxy" do
        script "#{haproxy_platform_options["service_bin"]} #{haproxy_platform_options["haproxy_service"]} status"
        interval 2
        action :create
        not_if {File.exists?('/etc/keepalived/conf.d/script_haproxy.conf')}
      end

      #Set keepalived state based on roles.
      rstate="BACKUP"
      if node.run_list.expand(node.chef_environment).roles.include?("openstack-ha-master")
        rstate="MASTER"
      end

      vrid = listen_ip.split(".")[3].to_i
      keepalived_vrrp vrrp_name do
        interface vrrp_interface
        virtual_ipaddress Array(listen_ip)
        virtual_router_id vrid
        track_script "haproxy"
        advert_int 1
        state rstate
        nopreempt
        notify_master "#{haproxy_platform_options["service_bin"]} haproxy restart ;  "
        notify_backup "#{haproxy_platform_options["service_bin"]} haproxy restart ; "
        notify_fault "#{haproxy_platform_options["service_bin"]} haproxy restart ; "
      end

      # now configure the virtual server
      Chef::Log.info("Configuring virtual_server for #{ns}-#{svc}")

      # Lookup listen_port from the environment, or fall back to the first searched node running the role
      listen_port = rcb_safe_deref(node, "#{ns}.services.#{svc}.port") ? node[ns]["services"][svc]["port"] : get_realserver_endpoints(role, ns, svc)[0]["port"]

      # Generate array of host:port real servers
      rs_list = get_realserver_endpoints(role, ns, svc).each.inject([]) { |output,x| output << x["host"] + ":" + x["port"].to_s }
      rs_list.sort!
      Chef::Log.debug "realserver list is #{rs_list}"

      haproxy_virtual_server "#{ns}-#{svc}" do
        lb_algo lb_algo
        mode lb_mode
        options lb_opts
        # zhiwei modify
        # vs_listen_ip listen_ip
        vs_listen_ip '0.0.0.0'
        vs_listen_port listen_port.to_s
        real_servers rs_list
      end

    else
      Chef::Log.info("Skipping service #{ns}-#{svc} as there are currently no back ends")
    end

  elsif
    listen_ip = rcb_safe_deref(node, "external-vips.#{ns}-#{svc}")
    Chef::Log.info("External vip found for #{ns}-#{svc}. Only updating keystone endpoint")
  end

  #unless listen_ip.nil?
  if listen_ip and get_role_count(role) > 0
    # Need to update keystone endpoint
    case svc_type
    when "ec2"
      public_endpoint = get_access_endpoint(role, ns, "api")
      admin_path = get_settings_by_role(role, ns)['services']['admin-api']['path']
      admin_endpoint = {'uri' => "#{public_endpoint['scheme']}://#{public_endpoint['host']}:#{public_endpoint['port']}#{admin_path}" }
    when "identity"
      public_endpoint = get_access_endpoint(role, ns, "service-api")
      admin_endpoint  = get_access_endpoint(role, ns, "admin-api")
    else
      public_endpoint = get_access_endpoint(role, ns, svc)
      admin_endpoint  = public_endpoint.clone
    end

    unless "#{ns}-#{svc}" == "glance-registry" ||
        "#{ns}-#{svc}" == "nova-xvpvnc-proxy" ||
        "#{ns}-#{svc}" == "nova-novnc-proxy" ||
        "#{ns}-#{svc}" == "horizon-dash" ||
        "#{ns}-#{svc}" == "horizon-dash_ssl"

      # I don't know why this line can't execute?
      Chef::Log.info("Sleep 5 seconds waiting for vip set up")
      execute "sleep-5-seconds" do
        command "sleep 5"
      end

      keystone_register "Recreate Endpoint" do
        auth_host ks_admin_endpoint["host"]
        auth_port ks_admin_endpoint["port"]
        auth_protocol ks_admin_endpoint["scheme"]
        api_ver ks_admin_endpoint["path"]
        auth_token keystone["admin_token"]
        service_type svc_type
        endpoint_region node["nova"]["compute"]["region"]
        endpoint_adminurl admin_endpoint['uri']
        endpoint_internalurl public_endpoint["uri"]
        endpoint_publicurl public_endpoint["uri"]
        retries 4
        retry_delay 5
        action :recreate_endpoint
      end

    end
  end

end
