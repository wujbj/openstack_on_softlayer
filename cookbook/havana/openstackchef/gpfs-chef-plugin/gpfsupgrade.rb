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
# Place in .chef/plugins/knife
#
## Usage:
# knife gpfs upgrade --master-node="devr1n31" --nodeslist-file="/root/gpfs/nodeslist.txt"  --roles-list="role[gpfs_update]"  --env-file="grizzly-devr1n32"  --rsa-file="/root/.ssh/id_rsa"  --disktro-option=rhel
###

require 'chef/knife'
require 'rubygems'

module MyGpfsUpgradeNamespace
 class GpfsUpgrade < Chef::Knife

  banner "knife gpfs Upgrade (options)"

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

        if config[:disktro_option]
      $disktro = config[:disktro_option]
      puts "disktro = #{$disktro}"
    end

    if config[:nodeslist_file]
      $nodes_file = config[:nodeslist_file]
      puts "nodes_file = #{$nodes_file}"
    end  
 
    if config[:rsa_file]
      $rsafile = config[:rsa_file]
      puts "rsafile = #{$rsafile}"
    end

    if config[:master_node]
      $masternodevalue = config[:master_node]
      puts "masternodevalue = #{$masternodevalue}"
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

  def get_roles_list(allroles)
    $roles_list = ""
    #allroles.each do |role|
    allroles.split(",").each do |role|
      $roles_list += role + ","
    end
    $roles_list = $roles_list.chop
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
        i = i + 1
       #if-end
       end
    #while-end
    end
    $hab.each do |single|
      puts "#{single[:name]} , #{single[:quorum]}"
    end
  end

  def run

    if config[:nodeslist_file].nil?
      system " knife gpfs upgrade --help "
      ui.fatal("You must specify correct command-line parameters!")
      exit 1
    end

    parse_parameters
    parse_nodeslist_file

    get_roles_list($rolesvalue)
    puts $roles_list

    #shutdown GPFS cluster and umount GPFS filesystem
    if config[:disktro_option].nil?
      system "knife bootstrap #{$masternodevalue} -i #{$rsafile} -r 'role[gpfs_shutdown]' -E #{$envfilename}"
    else
      system "knife bootstrap #{$masternodevalue} -i #{$rsafile} -r 'role[gpfs_shutdown]' -E #{$envfilename} -d #{$disktro}"
    end  

    #do upgrade opertion on every node in GPFS cluster
    $hab.each do |node|
      if node[:name].nil?
        next
      end
      puts "#{node[:ip]} ,===> #{node[:name]} ,===> #{node[:failuregroup]}"

      # To remove gpfs and it's dependicy software components on every node. one by one.
      if config[:disktro_option].nil?
        system "knife bootstrap #{node[:name]} -i #{$rsafile} -r '#{$roles_list}' -E #{$envfilename}" 
      else
        system "knife bootstrap #{node[:name]} -i #{$rsafile} -r '#{$roles_list}' -E #{$envfilename} -d #{$disktro}" 
      end
    #do-individual-node-end
    end
    #Restart GPFS cluster and mount GPFS filesystem
    if config[:disktro_option].nil?
      system "knife bootstrap #{$masternodevalue} -i #{$rsafile} -r 'role[gpfs_restart]' -E #{$envfilename}"
    else
      system "knife bootstrap #{$masternodevalue} -i #{$rsafile} -r 'role[gpfs_restart]' -E #{$envfilename} -d #{$disktro}"
    end  


  #run-end
  end
 #class-end
 end
#module-end
end
