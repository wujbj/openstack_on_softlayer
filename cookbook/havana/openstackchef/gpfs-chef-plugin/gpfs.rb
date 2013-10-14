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
# knife gpfs install --master-node="devr1n31" --second-node="devr1n33" --policy-file="/root/gpfs/policy-definition" --nodeslist-file="/root/nodeslist.txt" --diskslist-file="/root/diskslist.txt" --roles-list="role[gpfs_installation]"  --env-file="grizzly-devr1n32"   --rsa-file="/root/.ssh/id_rsa"  --disktro-option=rhel
###
# nodeslist-file
# node-IP,node-name,failure-group 
###
#
####
require 'chef/knife'
require 'rubygems'

module MyGpfsNamespace
 class Gpfs < Chef::Knife

  banner "knife gpfs install (options)"

  deps do
    require 'net/ssh'
    require 'net/ssh/multi'
    require 'readline'
    require 'chef/search/query'
    require 'chef/knife/search'
    require 'chef/mixin/command'
  end

  option :master_node,
    :long => "--master-node                Master node name or IP.",
    :description => "The master node name or IP."

  option :roles_list,
    :long => "--roles-list                 The new roles list.",
    :description => "The roles list, comma to sperate."

  option :policy_file,
    :long => "--policy-file                The policy file.",
    :description => "The policy file."

  option :second_node,
    :long => "--second-node                The second node name or ip address.",
    :description => "The second node ip address."

  option :env_file,
    :long => "--env-file                   The environment json filename.",
    :description => "The environment json filename."

  option :disktro_option,
    :long => "--disktro-option             The distro file under bootstrap.",
    :description => "Will be the value of -d option in kinfe bootstrap command."

  option :nodeslist_file,
    :long => "--nodeslist-file             The nodes list file.",
    :description => "The nodes list file, comma to sperate."

  option :diskslist_file,
    :long => "--diskslist-file             The disks list file.",
    :description => "The disk device information all the nodes."

  option :rsa_file,
    :long => "--rsa-file                   The ssh  rsa file.",
    :description => "The ssh rsa file"

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

    if config[:rsa_file]
      $rsafile = config[:rsa_file]
      puts "rsafile = #{$rsafile}"
    end

    if config[:roles_list]
      $rolesvalue = config[:roles_list]
      puts "rolesvalue = #{$rolesvalue}"
    end

    if config[:policy_file]
      $my_policy_file = config[:policy_file]
      puts "my_policy_file = #{$my_policy_file}"
    end

    if config[:second_node]
      $secondnode = config[:second_node]
      puts "secondnode = #{$secondnode}"
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
      system " knife gpfs install --help "
      ui.fatal("You must specify correct command-line parameters!")
      exit 1
    end

    parse_parameters

    parse_nodeslist_file

    get_roles_list($rolesvalue)
    puts $roles_list

    $hab.each do |node|
      if node[:name].nil?
        next
      end 
      puts "#{node[:name]} <===> #{node[:quorum]}"
      # To install gpfs and it's dependicy software components on every node. one by one.
      system "knife bootstrap #{node[:name]} -i #{$rsafile} -r '#{$roles_list}' -E #{$envfilename} -d #{$disktro}" 
    #do-individual-node-end
    end
    # On master node to configure and manage GPFS cluster
    system "scp -o StrictHostKeyChecking=no #{$nodes_file} #{$masternodevalue}:/tmp/gpfs_working/."
    system "scp -o StrictHostKeyChecking=no #{$disks_file} #{$masternodevalue}:/tmp/gpfs_working/."
    system "scp -o StrictHostKeyChecking=no #{$my_policy_file} #{$masternodevalue}:/tmp/gpfs_working/."
    system "echo \"#{$masternodevalue},#{$secondnode}\" > /tmp/master-second ; scp -o StrictHostKeyChecking=no /tmp/master-second #{$masternodevalue}:/tmp/gpfs_working/."

    system "knife bootstrap #{$masternodevalue} -i #{$rsafile} -r 'role[gpfs_deployment]' -E #{$envfilename} -d #{$disktro}" 
  #run-end
  end
 #class-end
 end
#module-end
end
