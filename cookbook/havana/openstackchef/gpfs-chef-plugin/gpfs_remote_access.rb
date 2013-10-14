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

###  Dai Baohua create the original file on Sep. 9th, 2013.
## Knife plugin to setup GPFS cluster.
#
## Install 
# Place in .chef/plugins/knife/gpfs_remote_access.rb
#
## Usage:
# knife gpfs remote mount --request-cluster-master="devr1n21" --provided-cluster-master="" --env-file="buddha-253" --rsa-file="/root/.ssh/id_rsa"  --disktro-option=rhel
###
# 1. Using comma to separate provided-cluster-nodes

require 'chef/knife'
require 'rubygems'

module MyGpfsRemoteMountNamespace
 class GpfsRemoteMount < Chef::Knife

  banner "knife gpfs remote mount (options)"

  deps do
    require 'net/ssh'
    require 'net/ssh/multi'
    require 'readline'
    require 'chef/search/query'
    require 'chef/knife/search'
    require 'chef/mixin/command'
  end

  option :request_cluster_master,
    :long => "--request-cluster-master    [ Master node name or IP of request GPFS cluster.]",
    :description => "The master node name or IP."

  option :provided_cluster_master,
    :long => "--provided-cluster-master   [ Master node name or IP of provided GPFS cluster.]",
    :description => "The master node name or IP of provided GPFS cluster."

  option :env_file,
    :long => "--env-file                  [ The environment json filename. ]",
    :description => "The environment json filename."

  option :disktro_option,
    :long => "--disktro-option rhel",
    :description => "Will be the value of -d option in kinfe bootstrap command."

  option :rsa_file,
    :long => "--rsa-file                  [ The ssh  rsa file. ]",
    :description => "The ssh rsa file."

  def parse_parameters

    if config[:request_cluster_master]
      $request_master_node = config[:request_cluster_master]
      puts "request_master_node = #{$request_master_node}"
    end

    if config[:provided_cluster_master]
      $provided_master_node = config[:provided_cluster_master]
      puts "provided_master_node = #{$provided_master_node}"
    end

    if config[:disktro_option]
      $disktro = config[:disktro_option]
      puts "disktro = #{$disktro}"
    end

    if config[:rsa_file]
      $rsafile = config[:rsa_file]
      puts "rsafile = #{$rsafile}"
    end

    if config[:env_file]
      $envfilename = config[:env_file]
      puts "envfilename = #{$envfilename}"
    end

  end

  def run

    if config[:request_cluster_master].nil? || config[:provided_cluster_master].nil?
      system " knife gpfs remote mount --help "
      ui.fatal("You must specify correct command-line parameters!")
      exit 1
    end

    parse_parameters

    puts "Step 1. On provided cluster #{$provided_master_node}, generate, update auth and transfer id_rsa.pub to request cluster #{$request_master_node}"
    system "knife bootstrap #{$provided_master_node} -i #{$rsafile} -r 'recipe[gpfs::provided_cluster_auth]' -E #{$envfilename} -d #{$disktro}" 

    puts "Step 2. On request cluster #{$request_master_node}, generate, update auth and transfer id_rsa.pub to provided cluster #{$provided_master_node}"
    system "knife bootstrap #{$request_master_node} -i #{$rsafile} -r 'recipe[gpfs::request_cluster_auth]' -E #{$envfilename} -d #{$disktro}" 

    puts "Step 3. Add and grant request cluster #{$request_master_node} to provided cluster #{$provided_master_node}"
    system "knife bootstrap #{$provided_master_node} -i #{$rsafile} -r 'recipe[gpfs::provided_cluster_add_grant]' -E #{$envfilename} -d #{$disktro}" 

    puts "Step 4. Add provided cluster #{$provided_master_node} and provided file sytem to request cluster #{$request_master_node}"
    system "knife bootstrap #{$request_master_node} -i #{$rsafile} -r 'recipe[gpfs::request_cluster_add]' -E #{$envfilename} -d #{$disktro}" 

  #run-end
  end
 #class-end
 end
#module-end
end
