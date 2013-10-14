action :create do
  log "Creating cinder.conf"

  #include_recipe "osops-utils"

  platform_options = node["cinder"]["platform"]

  ## Get MQ info
  mq_info = get_access_endpoint("os-ops-messaging","mq","mq")
  
  if mq_info.nil?
      puts mq_info
      puts "Get MQ info error"
      exit(1)
  end
  if node['openstack']['mq']['cluster']
      mq_info['host'] = node['openstack']['mq']['vip']
  end
  
  cinder_api = get_bind_endpoint("cinder", "api")
  cinder_volume_network = node["cinder"]["services"]["volume"]["network"]

  # Set iscsi address
  iscsi_ip_address = node["cinder"]["storage"]["iscsi"]["ip_address"]
  iscsi_ip_address ||= get_ip_for_net(cinder_volume_network)

  ## Old get cinder password
  # Check for which type of setup we are using here.
  # if cinder_info = get_settings_by_role("cinder", "cinder")
  #         Chef::Log.info("cinder::cinder-volume got cinder_info from cinder-setup role holder")
  # elsif cinder_info = get_settings_by_role("nova-volume", "cinder")
  #         Chef::Log.info("cinder::cinder-volume got cinder_info from nova-volume role holder")
  # elsif cinder_info = get_settings_by_recipe("cinder::cinder-setup", "cinder")
  #         Chef::Log.info("cinder::cinder-volume got cinder_info from cinder-setup recipe holder")
  # end

  ## Get secure cinder db password
  secure_db_password = get_passwords("cinder-db-password")
  if secure_db_password.nil?
    secure_db_password = node["cinder"]["db"]["password"]
  end

  # db_connection = get_db_connection(node["openstack"]["db"]["service_type"], node["cinder"]["db"]["name"], node["cinder"]["db"]["username"], cinder_info["db"]["password"])
 
db_user = node["openstack"]["volume"]["db"]["username"]
db_pass = db_password "cinder"
db_connection = db_uri("volume", db_user, db_pass)

  #db_connection = get_db_connection(node["openstack"]["db"]["service_type"], node["cinder"]["db"]["name"], node["cinder"]["db"]["username"], secure_db_password)

  # Currently we support SolidFire, EMC VMAX/VNX, NetApp ISCSI (onCommand), and NetApp NFSDirect
  storage_provider = node["cinder"]["storage"]["provider"]
  storage_options = {}
  case storage_provider
  when "solidfire"
	  storage_options["volume_driver"] = "cinder.volume.drivers.solidfire.SolidFire"
	  storage_options["san_ip"] = node["cinder"]["storage"][storage_provider]["mvip"]
	  storage_options["san_login"] = node["cinder"]["storage"][storage_provider]["username"]
	  storage_options["san_password"] = node["cinder"]["storage"][storage_provider]["password"]
  when "netappiscsi"
	  storage_options["volume_driver"] = "cinder.volume.drivers.netapp.NetAppISCSIDriver"
	  storage_options["netapp_wsdl_url"] = node["cinder"]["storage"]["netapp"]["iscsi"]["wsdl_url"]
	  storage_options["netapp_login"] = node["cinder"]["storage"]["netapp"]["iscsi"]["login"]
	  storage_options["netapp_password"] = node["cinder"]["storage"]["netapp"]["iscsi"]["password"]
	  storage_options["netapp_server_hostname"] = node["cinder"]["storage"]["netapp"]["iscsi"]["server_hostname"]
	  storage_options["netapp_server_port"] = node["cinder"]["storage"]["netapp"]["iscsi"]["server_port"]
	  storage_options["netapp_storage_service"] = node["cinder"]["storage"]["netapp"]["iscsi"]["storage_service"]
  when "netappnfsdirect"
	  storage_options["volume_driver"] = "cinder.volume.drivers.netapp.nfs.NetAppDirect7modeNfsDriver"
      storage_options["netapp_server_hostname"] = node["cinder"]["storage"]["netapp"]["nfsdirect"]["server_hostname"]
      storage_options["netapp_server_port"] = node["cinder"]["storage"]["netapp"]["nfsdirect"]["port"]
      storage_options["netapp_login"] = node["cinder"]["storage"]["netapp"]["nfsdirect"]["login"]
      storage_options["netapp_password"] = node["cinder"]["storage"]["netapp"]["nfsdirect"]["password"]
      storage_options["netapp_transport_type"] = node["cinder"]["storage"]["netapp"]["nfsdirect"]["transport_type"]
      storage_options["nfs_shares_config"] = node["cinder"]["storage"]["netapp"]["nfsdirect"]["nfs_shares_config"]
  when "emc"
	  storage_options["iscsi_target_prefix"] = "iqn.1992-04.com.emc"
	  storage_options["volume_driver"] = "cinder.volume.drivers.emc.emc_smis_iscsi.EMCSMISISCSIDriver"
	  storage_options["cinder_emc_config_file"] = "/etc/cinder/cinder_emc_config.xml"

  when "lvm"
      storage_options["volume_group"] = node["cinder"]["storage"]["lvm"]["volume_group"]
      storage_options["volume_clear"] = node["cinder"]["storage"]["lvm"]["volume_clear"]
      storage_options["volume_pool_size"] = node["cinder"]["storage"]["lvm"]["pool_size"]
  else
      msg = "#{storage_provider}, is not currently supported by these cookbooks. Please change the storage provider attribute in your environment to one of lvm, emc, solidfire, netappiscsi, netappnfsdirect."
      Chef::Application.fatal! msg
  end
  t = template "/etc/cinder/cinder.conf" do
	  source "cinder.conf.erb"
	  owner "cinder"
	  group "cinder"
	  mode "0600" 
	  variables(
		     "db_connection" => db_connection,
         "debug" => node["cinder"]["debug"],
         "verbose" => node["cinder"]["verbose"],
         "rabbit_ipaddress" => mq_info["host"],
         "rabbit_port" => mq_info["port"],
         "qpid_ipaddress" => mq_info["host"],
    		 "qpid_port" => mq_info["port"],
		     "notification_driver" => node["cinder"]["notification_driver"],
		     "cinder_api_listen_ip" => cinder_api["host"],
         "cinder_api_listen_port" => cinder_api["port"],
         "storage_availability_zone" => node["cinder"]["config"]["storage_availability_zone"],
         "max_gigabytes" => node["cinder"]["config"]["max_gigabytes"],
		     "storage_options" => storage_options,
                     "iscsi_ip_address" => iscsi_ip_address
          )
  end
  new_resource.updated_by_last_action(t.updated_by_last_action?)
end
