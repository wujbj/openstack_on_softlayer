#/******************************************************* {COPYRIGHT} ***
# * Licensed Materials - Property of IBM
# *
# * 5725-C88
# *
# * (C) Copyright IBM Corp. 2012, 2013 All Rights Reserved
# *
# * US Government Users Restricted Rights - Use, duplication or
# * disclosure restricted by GSA ADP Schedule Contract with
# * IBM Corp.
#******************************************************* {COPYRIGHT} ***/

###  Dai Baohua create the original file on Sep. 12th, 2013.
#
## Install 
# Place in .chef/plugins/knife/service_role.rb
#
## Usage:
# knife service role --role-list="openstack-keystone,openstack-cinder-api" --node-list="devr1n8,devr1n19,devr1n20" --action="[ start | stop | restart | status ]" [--env-file="only-gpfs"] --disktro-option=rhel --rsa-file="/root/.ssh/id_rsa"
# action = [ start | stop | restart | status ]
###

require 'chef/knife'
require 'rubygems'
require 'json'

module MyServiceRoleNamespace
 class ServiceRole< Chef::Knife

  banner "knife service role (options)"

  deps do
    require 'net/ssh'
    require 'net/ssh/multi'
    require 'readline'
    require 'chef/search/query'
    require 'chef/knife/search'
    require 'chef/mixin/command'
  end

  option :roles_list,
    :long => "--role-list          role-list",
    :description => "The role list, comma to sperate."

  option :nodes_list,
    :long => "--node-list          nodes-list",
    :description => "The upgrade nodes list, comma to sperate."

  option :db_server,
    :long => "--db-server database-server",
    :description => "The database sever address."

  option :db_user,
    :long => "--db-user database-user",
    :description => "The database user name."

  option :db_pass,
    :long => "--db-pass database-userpassword",
    :description => "The database user password."

  option :db_name,
    :long => "--db-name database-username",
    :description => "The database name."

  option :action_type,
    :long => "--action               action-type",
    :description => "The action type for specific node. [ start | stop | restart  ]"

  option :host_os,
    :long => "--host-os               Operating System of host",
    :description => "The host OS type for specific node. [ rhel | ubuntu ]"

  option :env_file,
    :long => "--env-file  environment-file",
    :description => "The environment json filename."

  option :disktro_option,
    :long => "--disktro-option rhel",
    :description => "Will be the value of -d option in kinfe bootstrap command."

  option :rsa_file,
    :long => "--rsa-file                   The ssh  rsa file.",
    :description => "The ssh rsa file"

  option :ssh_user,
    :short => "-x USERNAME",
    :long => "--ssh-user USERNAME",
    :description => "The ssh username"

  option :ssh_password,
    :short => "-P PASSWORD",
    :long => "--ssh-password PASSWORD",
    :description => "The ssh password"

  def get_parameters
    if config[:roles_list]
      $rolesvalue = config[:roles_list]
      #puts "services = #{$rolesvalue}"
    end
    if config[:nodes_list]
      $nodesvalue = config[:nodes_list]
      #puts "nodesvalue = #{$nodesvalue}"
    end
    if config[:db_server]
      $dbserver = config[:db_server]
      #puts "dbserver = #{$dbserver}"
    end
    if config[:db_user]
      $dbuser = config[:db_user]
      #puts "dbuser = #{$dbuser}"
    end
    if config[:db_name]
      $dbname = config[:db_name]
      #puts "dbname = #{$dbname}"
    end
    if config[:db_pass]
      $dbpass = config[:db_pass]
      #puts "dbpass = #{$dbpass}"
    end
    if config[:action_type]
      $actiontype = config[:action_type]
      #puts "actiontype = #{$actiontype}"
    end
    if config[:host_os]
      $hostos = config[:host_os]
      #puts "hostos = #{$hostos}"
    end
    if config[:env_file]
      $envfilename = config[:env_file]
      #puts "envfilename = #{$envfilename}"
    end
    if config[:disktro_option]
      $disktro = config[:disktro_option]
      #puts "disktro = #{$disktro}"
    end
    if config[:rsa_file]
      $rsafile = config[:rsa_file]
      #puts "rsafile = #{$rsafile}"
    end
    if config[:ssh_user]
      $sshuser = config[:ssh_user]
      #puts "sshuser = #{$sshuser}"
    end
    if config[:ssh_password]
      $sshpass = config[:ssh_password]
      #puts "sshpass = #{$sshpass}"
    end

  end

  def get_roles_list(allroles)
    $roles_list = ""
    #allroles.each do |role|
      #puts "allrole = #{allroles}"
    allroles.split(",").each do |role|
      #puts "role = #{role}"
      $roles_list += role + ","
    end
    $roles_list = $roles_list.chop
  end

  def generate_service_file(node_name,service,blockname)
    file = File.open("/tmp/#{node_name}-role-service","a+")
    file.puts "#{service},#{blockname}"
    file.close
  end

  def ssh_command(node,action,service_name,oshost)
    username=$sshuser
    password=""

    value = Array.new
    value = service_name.split("-",2)
    #puts "value[0] = #{value[0]}"
    #puts "value[1] = #{value[1]}"

    case oshost
      when 'rhel' 
        if value[0] == "openstack"
          parsed_service_name = service_name
        else
          head = "openstack-"
          parsed_service_name = head.to_s.concat(service_name) 
        end
      when 'ubuntu'
        begin
          if value[0] == "openstack"
            parsed_service_name = value[1]
          else
            parsed_service_name = service_name
          end
        end
    end
    #puts "parsed_service_name = #{parsed_service_name}"

    command_line = "service #{parsed_service_name} #{action}"
    ssh = Net::SSH.start(node, username, :password => password) do |ssh|
      result = ssh.exec!(command_line)
      puts result
    end
  end

  def parse_roles_list_file(node)
    if File.file?("/tmp/#{node}.roles")
      puts "File exist."
      file = File.open("/tmp/#{node}.roles","r")
    else    
      puts "The file /tmp/#{node}.roles does not exist, please generate this file firstly."
      exit 1   
    end 
    i = 0   
    while(lines = file.gets)
        a = lines.split(",")
        #puts "a.length = #{a.length}"
        service_name = Array.new
        block_name = Array.new

        a.each do |role|
          role_lstrip = role.lstrip
          only_value = role_lstrip.rstrip
          rep_only_value = only_value.gsub('-','_')
          puts "rep_only_value = #{rep_only_value}"
          component_num = 0
          service_num = 0
          $component_hash.each do |key, value|
            if key == rep_only_value
              block_name[component_num] = value
              component_num = component_num + 1
              next
            elsif key.include?(rep_only_value)
              block_name[component_num] = value
              component_num = component_num + 1
              next
            else
              next
            end 
          #component_hash-end
          end 
          $roles_hash.each do |key, value|
            if key == rep_only_value
              service_name[service_num] = value
              service_num = service_num + 1
              next
            elsif key.include?(rep_only_value)
              service_name[service_num] = value
              service_num = service_num + 1
              next
            else
              next
            end 
          #roles_hash-end
          end 
          if service_num == 0
            next
          else
            service_component_num = service_num - 1
            begin
              puts "service_component_num = #{service_component_num} , service_name[#{service_component_num}] = #{service_name[service_component_num]}"
              if ! service_name[service_component_num].nil?
                generate_service_file(node,service_name[service_component_num],block_name[service_component_num])
              end
              service_component_num = service_component_num - 1
            end until service_component_num == -1
          end
          service_name.clear
          block_name.clear
        #a-each-end
        end
    #while-end
    end
    file.close()
  end

  def run

    # The map between role and service
    $roles_hash = Hash.new
    $roles_hash = {
      "os_block_storage_api" => "cinder_api_service" ,
      "os_block_storage_scheduler" => "cinder_scheduler_service" ,
      "os_block_storage_volume" => "cinder_volume_service" ,
      "os_compute_api_metadata" => "compute_api_metadata_service" ,
      "os_compute_api" => "api_os_compute_service" ,
      "os_compute_client" => "compute_compute_service" ,
      "os_compute_conductor" => "compute_conductor_service" ,
      "os_compute_scheduler" => "compute_scheduler_service" ,
      "os_compute_vncproxy_proxy" => "compute_vncproxy_service",
      "os_compute_vncproxy_consoleauth" => "compute_vncproxy_consoleauth_service",
      "os_compute_cert" => "compute_cert_service",
      "os_identity" => "keystone_service" ,
      "os_image_api" => "image_api_service" ,
      "os_image_registry" => "image_registry_service" ,
      "os_network_api" => "quantum_server_service" ,
      "os_network_dhcp_agent" => "quantum_dhcp_agent_service" ,
      "os_network_l3_agent" => "quantum_l3_agent_service" ,
      "os_network_metadata_agent" => "quantum_metadata_agent_service" ,
      "os_network_plugin_agent" => "quantum_openvswitch_agent_service"
    }

    # The map between component/block/directory under cookbooks and role
    $component_hash = Hash.new
    $component_hash = {
      "os_block_storage_api" => "openstack-block-storage" ,
      "os_block_storage_scheduler" => "openstack-block-storage" ,
      "os_block_storage_volume" => "openstack-block-storage" ,
      "os_compute_api_metadata" => "openstack-compute" ,
      "os_compute_api" => "openstack-compute" ,
      "os_compute_client" => "openstack-compute" ,
      "os_compute_conductor" => "openstack-compute" ,
      "os_compute_scheduler" => "openstack-compute" ,
      "os_compute_vncproxy_proxy" => "openstack-compute",
      "os_compute_vncproxy_consoleauth" => "openstack-compute",
      "os_compute_cert" => "openstack-compute",
      "os_identity" => "openstack-identity" ,
      "os_image_api" => "openstack-image" ,
      "os_image_registry" => "openstack-image" ,
      "os_network_api" => "openstack-network" ,
      "os_network_dhcp_agent" => "openstack-network" ,
      "os_network_l3_agent" => "openstack-network" ,
      "os_network_metadata_agent" => "openstack-network" ,
      "os_network_plugin_agent" => "openstack-network"
    }

    if config[:nodes_list].nil?
      system " knife service role --help "
      ui.fatal("You must specify correct command-line parameters!")
      exit 1
    end

    get_parameters
   
    nodes_num = 1
    $nodesvalue.split(",").each do |node| 

      ###puts "node ==============> #{node}"
      if File.exist?("/tmp/#{node}-role-service")
        File.delete("/tmp/#{node}-role-service")
      end
      if config[:roles_list].nil?
        # need use command knife node show #{node} to obtain which role need be generated.
        system "knife node show #{$node_name} | grep Roles | grep -v grep | awk -F ':' '{print $2}' > /tmp/#{$node}.roles"
        parse_roles_list_file(node)
      else
        #get_roles_list($rolesvalue)
        ###puts "rolesvalue = #{$rolesvalue}"
        service_name = Array.new
        block_name = Array.new

        $rolesvalue.split(",").each do |role|
          #puts "Handle role   ==============> #{role}"
          role_lstrip = role.lstrip
          only_value = role_lstrip.rstrip
          rep_only_value = only_value.gsub('-','_')
          component_num = 0 
          service_num = 0 
          $component_hash.each do |key, value|
            if key == rep_only_value
              block_name[component_num] = value
              component_num = component_num + 1
              next
            elsif key.include?(rep_only_value)
              block_name[component_num] = value
              component_num = component_num + 1
              next
            else
              next
            end 
          #component_hash-end
          end 
          $roles_hash.each do |key, value|
            if key == rep_only_value
              service_name[service_num] = value
              service_num = service_num + 1
              next
            elsif key.include?(rep_only_value)
              service_name[service_num] = value
              service_num = service_num + 1
              next
            else
              next
            end 
          #roles_hash-end
          end 
          service_component_num = service_num - 1
          begin
            generate_service_file(node,service_name[service_component_num],block_name[service_component_num])
            service_component_num = service_component_num - 1
          end until service_component_num == -1
          service_name.clear
          block_name.clear
        #rolesvalue-end
        end
      #if-roles-list-end
      end
    
    cookbook_name = "openstack-service-ibm"
    system "scp -o StrictHostKeyChecking=no /tmp/#{node}-role-service #{node}:/tmp/role-service 1>/dev/null 2>&1 "
    if $envfilename.nil?
      system "knife bootstrap #{node} -r 'recipe[#{cookbook_name}::service_#{$actiontype}]' -i #{$rsafile} -d #{$disktro} 1>/dev/null 2>&1"
    else
      system "knife bootstrap #{node} -r 'recipe[#{cookbook_name}::service_#{$actiontype}]' -i #{$rsafile} -E #{$envfilename} -d #{$disktro} 1>/dev/null 2>&1"
    end

      #### if $actiontype == "status"
        system " if [ -f /tmp/#{node}-exact-service-name ] ; then rm -rf /tmp/#{node}-exact-service-name ; fi ; scp -o StrictHostKeyChecking=no #{node}:/tmp/exact-service-name /tmp/#{node}-exact-service-name 1>/dev/null 2>&1  "
        file = File.open("/tmp/#{node}-exact-service-name","r")
        
        puts "NODE #{nodes_num} ===========> #{node}"
        while(lines = file.gets)
          l_lines = lines.lstrip
          exact_service = l_lines.rstrip
          puts "Service Name = [ #{exact_service} ]"
          command_line = "service #{exact_service} #{$actiontype}"
          username=$sshuser
          password=$sshpass
          ###ssh = Net::SSH.start(node, username, :password => password) do |ssh|
          ssh = Net::SSH.start(node, username) do |ssh|
            result = ssh.exec!(command_line)
            puts result
          end
          puts ""
        #while-end
        end
        file.close
      #if-status-end
      #### end
      
    nodes_num = nodes_num + 1
    #nodesvalue-end
    end

  #run-end
  end
 #class-end
 end
#module-end
end
