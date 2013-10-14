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
# Place in .chef/plugins/knife/upgrade.rb
#
## Usage:
# knife node upgrade_info --nodes-list="devr1n23,devr1n43,devr1n53" --chef-server="127.0.0.1" --node-type="compute"
#
###

require 'chef/knife'
require 'chef/couchdbupgrade'
require 'rubygems'
require 'json'

module MyUpgradeInfospace
 class NodeUpgradeInfo < Chef::Knife

  banner "knife node upgrade_info (options)"

  deps do
    require 'readline'
  end

  option :nodes_list,
    :long => "--nodes-list upgrade nodes list.",
    :description => "The upgrade nodes list, comma to sperate."

  option :chef_server,
    :long => "--chef-server  the chef-server address.",
    :description => "The chef sever address."

  option :node_type,
    :long => "--node-type the type of upgrade node.",
    :description => "The node type of upgrade node.[ cinder | compute | controller  ]"

  def get_parameters
    if config[:nodes_list]
      $nodesvalue = config[:nodes_list]
      puts "nodesvalue = #{$nodesvalue}"
    end
    if config[:chef_server]
      $chefserver = config[:chef_server]
      puts "chefserver = #{$chefserver}"
    end
    if config[:node_type]
      $nodetype = config[:node_type]
      puts "nodetype = #{$nodetype}"
    end
  end

=begin
    option :myconfig,
    :short => "-f config-file",
    :long => "--config-file config-file",
    :description => "The number of seconds between batches."

  def get_parameters
    if File.file?("#{$conf_file}")
      file = File.open("#{$conf_file}","r")
    else
      puts "The file #{$conf_file} does not exist, please generate this file firstly."
      exit 1
    end

    while(lines = file.gets)
      if not lines.match(/^#/)
        a = lines.split("=")
          case a[0]
            when "chef_server" :
              $chefserver = a[1].chomp
            when "nodes_list" : 
              $nodesvalue = a[1].chomp
            when "node_type" : 
              $nodetype = a[1].chomp
          #case-end
          end
       #if-end
       end
    #while-end
    end
  end
=end
  def json_to_hash(jsonobj,node,type)
    #puts jsonobj
    json_result = JSON.parse(jsonobj)
    #puts "json_result =========================================>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>"
    #puts json_result
    if not json_result.nil?
      case type
        when "yum" :
          puts "_id =========> #{json_result['_id']}"
          puts "_rev ========> #{json_result['_rev']}"
          puts "node ========> #{json_result['node']}"
          puts "version =====> #{json_result['version']}"
          puts "noarch_url ==> #{json_result['noarch_url']}"
          puts "x86_64_url ==> #{json_result['x86_64_url']}"
          puts "patch_url ===> #{json_result['patch_url']}"
          #puts => #{json_result['apply_time']}"
        when 'state' :
          puts "chef-server ===> #{json_result['chef-server']}"
          puts "from-version ==> #{json_result['from-version']}"
          puts "end-version ===> #{json_result['end-version']}"
          puts "update-time ===> #{json_result['update-time']}"
          puts "apply_time ====> #{json_result['apply_time']}"
      end
    end
  end

  def run
=begin
    if config[:myconfig].nil?
      #show_usage
      system " knife node upgrade --help "
      ui.fatal("You must specify correct command-line parameters!")
      exit 1
    end

    if config[:myconfig]
      puts config[:myconfig]
      $conf_file = config[:myconfig]
    end
=end
    get_parameters

    $couch_server = UpgradeCouchDB::CouchServer.new($chefserver,"5984")
    # create "upgrade_db" database
    #$couch_server.put("/upgrade_db","Hello World!")
    #puts "connected to couchdb"

    $nodesvalue.split(",").each do |node| 

      puts "node ==============> #{node} begin ================================================="

      yum_doc = $couch_server.get("/upgrade_db/#{node}-yum")
      #puts "yum_doc ================================= >"
      #puts  yum_doc

      json_to_hash(yum_doc,node,"yum")
      state_doc = $couch_server.get("/upgrade_db/#{node}-state")
      json_to_hash(state_doc,node,"state")

      puts "node ==============> #{node} end  ================================================="

    end
  #run-end
  end
 #class-end
 end
#module-end
end
