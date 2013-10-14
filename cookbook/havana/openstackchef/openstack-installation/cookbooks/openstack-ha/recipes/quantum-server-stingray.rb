#
# Cookbook Name:: openstack-ha
# Recipe:: quantum-stingray
#
# Copyright 2013, IBM
#
# All rights reserved - Do Not Redistribute
#

ks_admin_endpoint = get_access_endpoint("keystone", "keystone", "admin-api", "endpoint")
keystone = get_settings_by_role("keystone","keystone")

node["ha"]["available_services"]["quantum"].each do |s|

    role, ns, svc, svc_type = s["role"], s["namespace"], s["service"], s["service_type"]

    # See if a vip has been defined for this service, if yes create a vrrp and virtual server definition
    if vip = rcb_safe_deref(node, "vips.#{ns}-#{svc}")

        # make sure we have some back ends
        if get_role_count(role) > 0

            Chef::Log.info("Configuring traffic ip for #{ns}-#{svc}")
            stingray_flipper "#{vip}" do
                ipaddress vip
            end
    
            Chef::Log.info("Getting real_server ip:port list")
            vport = rcb_safe_deref(node, "#{ns}.services.#{svc}.port") ? node[ns]["services"][svc]["port"] : get_realserver_endpoints(role, ns, svc)[0]["port"]
            rs_list = get_realserver_endpoints(role, ns, svc).each.inject([]) { |output,x| output << x["host"] + ":" + x["port"].to_s }
            rs_list.sort!
            Chef::Log.debug "realserver list is #{rs_list}"
    
            puts "======================="
            puts rs_list
            puts vport
            puts "======================="

            Chef::Log.info("Configuring stingray pool for #{ns}-#{svc}")
            stingray_pool "#{ns}-#{svc}" do
                nodes rs_list
            end
    
            Chef::Log.info("Configuring stingray vserver for #{ns}-#{svc}")
            stingray_vserver "#{ns}-#{svc}" do
                port vport.to_i
                pool "#{ns}-#{svc}"
            end
        end
    end

    #unless listen_ip.nil?
    if vip and get_role_count(role) > 0
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
    
            Chef::Log.info("Sleep 5 seconds waiting for setup #{ns}-#{svc} vip")
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
