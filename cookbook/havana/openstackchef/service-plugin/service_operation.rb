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

###  Dai Baohua create the original file on Sep. 4th, 2013.
## Knife plugin to upgrade openstack components to NODE 
#
## Install 
# Place in .chef/plugins/knife/upgrade.rb
#
## Usage:
# knife service operate --service-list="iptables" --node-list="172.16.1.138" --action="status" --disktro-option=rhel --ssh-user=root
# action = [ start | stop | restart  | status]
###

require 'chef/knife'
require 'rubygems'
require 'json'

module MyServiceOperateNamespace
 class ServiceOperate< Chef::Knife

  banner "knife service operate (options)"

  deps do
    require 'net/ssh'
    require 'net/ssh/multi'
    require 'readline'
    require 'chef/search/query'
    require 'chef/knife/search'
    require 'chef/mixin/command'
  end

  option :roles_list,
    :long => "--service-list          service-list",
    :description => "The service list, comma to sperate."

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
      puts "dbserver = #{$dbserver}"
    end
    if config[:db_user]
      $dbuser = config[:db_user]
      puts "dbuser = #{$dbuser}"
    end
    if config[:db_name]
      $dbname = config[:db_name]
      puts "dbname = #{$dbname}"
    end
    if config[:db_pass]
      $dbpass = config[:db_pass]
      puts "dbpass = #{$dbpass}"
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
      puts "rsafile = #{$rsafile}"
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
    allroles.split(",").each do |role|
      $roles_list += role + ","
    end
    $roles_list = $roles_list.chop
  end

  def ssh_command(node,action,service_name)
    username=$sshuser
    password=""

    parsed_service_name = service_name
    #puts "parsed_service_name = #{parsed_service_name}"

    #puts "NODE #{nodenum} ========>   #{node}"
    command_line = "service #{parsed_service_name} #{action}"
    #ssh = Net::SSH.start(node, username, :password => password) do |ssh|
    ssh = Net::SSH.start(node, username) do |ssh|
      result = ssh.exec!(command_line)
      puts result
    end
  end

  def run

    if config[:roles_list].nil? || config[:nodes_list].nil?
      system " knife service operate --help "
      ui.fatal("You must specify correct command-line parameters!")
      exit 1
    end

    get_parameters

    get_roles_list($rolesvalue)

    #puts $roles_list
   
    nodes_num = 1
    $nodesvalue.split(",").each do |node| 

      puts "NODE [ #{nodes_num} ] ------------------------------------- [ #{node} ]"
      service_num = 1
      $rolesvalue.split(",").each do |service_name|
        puts "Handle service [ #{service_num} ] ====================> [ #{service_name} ]"
        ssh_command(node,$actiontype,service_name)
        puts ""
        service_num = service_num + 1
      #rolesvalue-end
      end
    nodes_num = nodes_num + 1
    #nodesvalue-end
    end

  #run-end
  end
 #class-end
 end
#module-end
end
