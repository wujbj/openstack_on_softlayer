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
# Place in .chef/plugins/knife/gpfs_applypolicy.rb
#
## Usage:
# knife gpfs apply policy --master-node="devr1n21" --nodes-list="/root/gpfs/apply_policy_nodes" --policy-file="/root/gpfs/policy_definition" --roles-list="role[gpfs_apply_policy]"  --env-file="buddha-253"  --rsa-file="/root/.ssh/id_rsa"  --disktro-option=rhel
###
# apply_policy_nodes
# node-name1
# node-name2
# ... 
###
#
####
require 'chef/knife'
require 'rubygems'

module MyGpfsApplyPolicyNamespace
 class GpfsApplyPolicy < Chef::Knife

  banner "knife gpfs apply policy (options)"

  deps do
    require 'net/ssh'
    require 'net/ssh/multi'
    require 'readline'
    require 'chef/search/query'
    require 'chef/knife/search'
    require 'chef/mixin/command'
  end

  option :master_node,
    :long => "--master-node                The master node name or IP.",
    :description => "The master node name or IP."

  option :roles_list,
    :long => "--roles-list                 The roles list, comma to sperate.",
    :description => "The roles list, comma to sperate."

  option :policy_file,
    :long => "--policy-file                The policy file.",
    :description => "The policy file."

  option :env_file,
    :long => "--env-file                   The environment json filename.",
    :description => "The environment json filename."

  option :disktro_option,
    :long => "--disktro-option             The distro file under bootstrap.",
    :description => "Will be the value of -d option in kinfe bootstrap command."

  option :nodeslist_file,
    :long => "--nodeslist-file             The nodes list file.",
    :description => "The nodes list file, comma to sperate."

  option :rsa_file,
    :long => "--rsa-file                   The ssh  rsa file.",
    :description => "The ssh rsa file."

  def parse_parameters
    if config[:master_node]
      $masternodevalue = config[:master_node]
      puts "masternodevalue = #{$masternodevalue}"
    end

    if config[:disktro_option]
      $disktro = config[:disktro_option]
      puts "disktro = #{$disktro}"
    end

    if config[:nodeslist_file]
      $nodes_file = config[:nodeslist_file]
      puts "nodes_file = #{$nodes_file}"
    end

    if config[:diskslist_file]
      $disks_file = config[:diskslist_file]
      puts "disks_file = #{$disks_file}"
    end

    if config[:policy_file]
      $my_policy_file = config[:policy_file]
      puts "my_policy_file = #{$my_policy_file}"
    end

    if config[:rsa_file]
      $rsafile = config[:rsa_file]
      puts "rsafile = #{$rsafile}"
    end

    if config[:roles_list]
      $rolesvalue = config[:roles_list]
      puts "rolesvalue = #{$rolesvalue}"
    end

    if config[:env_file]
      $envfilename = config[:env_file]
      puts "envfilename = #{$envfilename}"
    end

  end

  def parse_nodeslist_file
    if File.file?("#{$nodes_file}")
      file = File.open("#{$nodes_file}","r")
    else    
      puts "The file #{$nodes_file} does not exist, please generate this file firstly."
      exit 1  
    end
    b = Hash.new
    $hab = Array.new
    i = 0   
    while(lines = file.gets)
      if lines.match(/^(#|' ')/) || lines.length() < 3
        next
      end
      if not lines.match(/^(#|' ')/)
        a = lines.split(":")
        b = {:name => a[0],:quorum => a[1]}
        $hab[i] = b
        #puts "#{$hab[i][:name]} , #{$hab[i][:quorum]}"
        i = i + 1 
       #if-end 
       end     
    #while-end
    end
    $hab.each do |single|
    puts " #{single[:name]} , #{single[:quorum]}"
    end
  end

  def get_roles_list(allroles)
    $roles_list = ""
    allroles.split(",").each do |role|
      $roles_list += role + ","
    end
    $roles_list = $roles_list.chop
  end

  def run

    if config[:nodeslist_file].nil?
      system " knife gpfs apply policy --help "
      ui.fatal("You must specify correct command-line parameters!")
      exit 1
    end

    parse_parameters

    #parse_nodeslist_file

    get_roles_list($rolesvalue)
    puts $roles_list

    # On master node to add nodes to GPFS cluster
    system "scp -o StrictHostKeyChecking=no #{$my_policy_file} #{$masternodevalue}:/tmp/gpfs_working/."
    system "scp -o StrictHostKeyChecking=no #{$nodes_file} #{$masternodevalue}:/tmp/gpfs_working/."
    system "knife bootstrap #{$masternodevalue} -i #{$rsafile} -r '#{$roles_list}' -E #{$envfilename} -d #{$disktro}" 

  #run-end
  end
 #class-end
 end
#module-end
end
