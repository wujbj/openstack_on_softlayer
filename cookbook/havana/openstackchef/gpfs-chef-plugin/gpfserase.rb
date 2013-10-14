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

###  Dai Baohua create the original file on Apr. 23th, 2013.
## Knife plugin to setup GPFS cluster.
#
## Install 
# Place in .chef/plugins/knife/gpfs.rb
#
## Usage:
#knife gpfs erase --master-node="devr1n31"  --roles-list="role[gpfs_deletion]"  --env-file="grizzly-devr1n32"  --rsa-file="/root/.ssh/id_rsa"  --disktro-option=rhel
###

require 'chef/knife'
require 'rubygems'

module MyGpfsEraseNamespace
 class GpfsErase < Chef::Knife

  banner "knife gpfs erase (options)"

  deps do
    require 'net/ssh'
    require 'net/ssh/multi'
    require 'readline'
    require 'chef/search/query'
    require 'chef/knife/search'
    require 'chef/mixin/command'
  end

  option :master_node,
    :long => "--master-node               Master node name or IP.",
    :description => "The master node name or IP."

  option :roles_list,
    :long => "--roles-list                The roles list.",
    :description => "The roles list, comma to sperate."

  option :env_file,
    :long => "--env-file                  The environment json filename.",
    :description => "The environment json filename."

  option :disktro_option,
    :long => "--disktro-option            The distro file under bootstrap.",
    :description => "Will be the value of -d option in kinfe bootstrap command."

  option :rsa_file,
    :long => "--rsa-file                  The ssh  rsa file.",
    :description => "The ssh rsa file."

  def parse_parameters

        if config[:disktro_option]
      $disktro = config[:disktro_option]
      puts "disktro = #{$disktro}"
    end

    if config[:rsa_file]
      $rsafile = config[:rsa_file]
      puts "rsafile = #{$rsafile}"
    end

    if config[:master_node]
      $masternodevalue = config[:master_node]
      puts "masternodevalue = #{$masternodevalue}"
    end

    if config[:cluster_name]
      $clustername = config[:cluster_name]
      puts "clustername = #{$clustername}"
    end

    if config[:roles_list]
      $rolesvalue = config[:roles_list]
      puts "rolesvalue = #{$rolesvalue}"
    end

    if config[:nodes_list]
      $nodesvalue = config[:nodes_list]
      puts "nodesvalue = #{$nodesvalue}"
    end
    if config[:second_node]
      $secondnode = config[:second_node]
      puts "secondnode = #{$secondnode}"
    end

    if config[:env_file]
      $envfilename = config[:env_file]
      puts "envfilename = #{$envfilename}"
    end

    if config[:gpfs_repo]
      $gpfsrepo = config[:gpfs_repo]
      puts "gpfsrepo = #{$gpfsrepo}"
    end

    if config[:ssh_user]
      $sshuser = config[:ssh_user]
      puts "sshuser = #{$sshuser}"
    end
    if config[:ssh_password]
      $sshpass = config[:ssh_password]
      puts "sshpass = #{$sshpass}"
    end
  end

  def get_roles_list(allroles)
    $roles_list = ""
    allroles.split(",").each do |role|
      $roles_list += role + ","
    end
    $roles_list = $roles_list.chop
  end
=begin
  def parse_nodeslist_file
    if File.file?("#{$nodes_file}")
      file = File.open("#{$nodes_file}","r")
    else
      puts "The file #{$nodes_file} does not exist, please generate this file firstly."
      exit 1
    end
    #b = Hash.new
    $hab = Array.new
    i = 0
    while(lines = file.gets)
     if lines.match(/^(#|' ')/) || lines.length() < 3
        next
      end
      if not lines.match(/^(#|' ')/)
        #a = lines.split(":")
        #b = {:name => a[0],:quorum => a[1]}
        $hab[i] = lines.chomp
        i = i + 1
       #if-end
       end
    #while-end
    end
    $hab.each do |single|
      puts "#{single}"
    end
  end
=end
  def parse_nodes_file(current_nodes_file)
    puts "The file #{current_nodes_file}" 
    if File.file?("#{current_nodes_file}")
      file = File.open("#{current_nodes_file}","r")
    else
      puts "The file #{current_nodes_file} does not exist, please generate this file firstly."
      exit 1
    end
    $hab = Array.new
    i = 0
    while(lines = file.gets)
     if lines.match(/^(#|' ')/) || lines.length() < 3
        next
      end
      if not lines.match(/^(#|' ')/)
        $hab[i] = lines.chomp
        i = i + 1
       #if-end
       end
    #while-end
    end
    $hab.each do |single|
      puts "#{single}"
    end
  end

  def run

    if config[:master_node].nil?
      system " knife gpfs erase --help "
      ui.fatal("You must specify correct command-line parameters!")
      exit 1
    end

    parse_parameters
    #parse_nodeslist_file

    get_roles_list($rolesvalue)
    puts $roles_list
    
    #stop_GPFS_on_master_node
    system "knife bootstrap #{$masternodevalue} -i #{$rsafile} -r 'role[gpfs_termination]' -E #{$envfilename} -d #{$disktro}"

    #get all nodes name in current cluster
    system "scp -o StrictHostKeyChecking=no  #{$masternodevalue}:/tmp/gpfs_working/current-nodes /tmp/."
    parse_nodes_file("/tmp/current-nodes")

    $hab.each do |node|
      if node.nil?
        next
      end
      puts "#{node}"

      # To remove gpfs and it's dependicy software components on every node. one by one.
      system "knife bootstrap #{node} -i #{$rsafile} -r '#{$roles_list}' -E #{$envfilename} -d #{$disktro}" 
    #do-individual-node-end
    end

  #run-end
  end
 #class-end
 end
#module-end
end
