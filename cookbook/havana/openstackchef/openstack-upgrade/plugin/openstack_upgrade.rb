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

###  Dai Baohua create the original file on Mar. 23th, 2013.
## Knife plugin to upgrade openstack components to NODE 
#
## Install 
# Place in .chef/plugins/knife/openstack_upgrade.rb
#
## Usage:
# knife openstack upgrade --repo-url="http://172.16.0.4:8080/sce3/rpms" --latest-version="/var/www/html/sce3/rpms/gts/D20130605-1352" --roles-list="role[openstack-upgrade]" --nodes-list="devr1n32,devr1n33,devr1n23,devr1n22" --env-file="grizzly-devr1n32" --rsa-file="/root/.ssh/id_rsa"  --disktro-option=rhel
###

require 'chef/knife'
require 'rubygems'
require 'json'
require 'mysql'

module MyOpenstackUpgradeNamespace
 class OpenstackUpgrade < Chef::Knife

  banner "knife openstack upgrade (options)"

  deps do
    require 'net/ssh'
    require 'net/ssh/multi'
    require 'readline'
    require 'chef/search/query'
    require 'chef/knife/search'
    require 'chef/mixin/command'
  end

  option :repo_url,
    :long => "--repo-url openstack-new-repo",
    :description => "The new openstack repository URL ."

  option :patch_url,
    :long => "--patch-url openstack-patch-repo",
    :description => "The openstack patch repository URL ."

  option :latest_version,
    :long => "--latest-version openstack-new-repo",
    :description => "The latest openstack version directory."

  option :disktro_option,
    :long => "--disktro-option rhel",
    :description => "Will be the value of -d option in kinfe bootstrap command."

  option :rsa_file,
    :long => "--rsa-file  << the ssh  rsa file.>>",
    :description => "The ssh rsa file."

  option :roles_list,
    :long => "--roles-list roles-list",
    :description => "The roles list, comma to sperate."

  option :nodes_list,
    :long => "--nodes-list nodes-list",
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

  option :env_file,
    :long => "--env-file  environment-file",
    :description => "The environment json filename."

  def get_parameters
    if config[:repo_url]
      $repovalue = config[:repo_url]
      puts "repovalue = #{$repovalue}"
    end
    if config[:patch_url]
      $patchvalue = config[:patch_url]
      puts "patchvalue = #{$patchvalue}"
    end
    if config[:latest_version]
      $version_value = config[:latest_version]
      puts "version_value = #{$version_value}"
    end 
    if config[:disktro_option]
      $disktro = config[:disktro_option]
      puts "disktro = #{$disktro}"
    end 
    if config[:rsa_file]
      $rsafile = config[:rsa_file]
      puts "rsafile = #{$rsafile}"
    end
    if config[:roles_list]
      $rolesvalue = config[:roles_list]
      puts "rolesvalue = #{$rolesvalue}"
    end
    if config[:nodes_list]
      $nodesvalue = config[:nodes_list]
      puts "nodesvalue = #{$nodesvalue}"
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
    if config[:env_file]
      $envfilename = config[:env_file]
      puts "envfilename = #{$envfilename}"
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

  def generate_new_repo(node,repourl)

    file = File.new("/tmp/openstack_#{node}_allinone.repo","w+")
    file.puts "[openstack_allinone]"
    file.puts "name=openstack_allinone_directory"
    if repourl[-1,1] == "/"
      file.puts "baseurl=#{repourl}"
    else
      file.puts "baseurl=#{repourl}/"
    end
    file.puts "enabled=1"
    file.puts "gpgcheck=0"
    file.close

  end

  def parse_lastet_version_directory(latest_dir)
puts " latest_dir = #{latest_dir}"
    $latest = latest_dir.split('/')[-1]
  end

  def generate_patch_repo(node,patchurl)

    file = File.new("/tmp/openstack_#{node}_patch.repo","w+")
    file.puts "[openstack_patch]"
    file.puts "name=openstack_patch"
    if patchurl[-1,1] == "/"
      file.puts "baseurl=#{patchurl}"
    else
      file.puts "baseurl=#{patchurl}/"
    end
    file.puts "enabled=1"
    file.puts "gpgcheck=0"
    file.close

  end

  def run

    if config[:nodes_list].nil?
      system " knife openstack upgrade --help "
      ui.fatal("You must specify correct command-line parameters!")
      exit 1
    end

    get_parameters

    get_roles_list($rolesvalue)

    puts $roles_list

    parse_lastet_version_directory($version_value)
   
    $nodesvalue.split(",").each do |node| 

      puts "node ==============> #{node}"

      # generate yum repos files for #{node}
      generate_new_repo(node,$repovalue)
      #generate_patch_repo(node,$patchvalue)

      system "scp /tmp/openstack_#{node}_allinone.repo root@#{node}:/etc/yum.repos.d/openstack-#{node}-allinone.repo 1>/dev/null 2>&1"

      # We should transform the latest patch RPMs to target node, in order to use 'yum install' command to install them.
      system "echo #{$latest} > /tmp/latest ; scp /tmp/latest root@#{node}:/tmp/.  ;  scp -r #{$version_value} root@#{node}:/tmp/."

      #####system "scp /tmp/openstack_#{node}_patch.repo root@#{node}:/etc/yum.repos.d/openstack-#{node}-patch.repo 1>/dev/null 2>&1"
      
      system "knife bootstrap #{$node} -i #{$rsafile} -r '#{$roles_list}' -E #{$envfilename} -d #{$disktro}"

    #do-individual-node-end
    end
    
  #run-end
  end
 #class-end
 end
#module-end
end
