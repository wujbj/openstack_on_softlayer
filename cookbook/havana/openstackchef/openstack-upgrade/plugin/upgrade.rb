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
#knife node upgrade --new-version="1.0.2" --repo-url="http://172.16.1.32/openstack/1.0.2" --roles-list="ROLE[AAA],role[BBB],role[CCC],role[DDD]" --nodes-list="devr1n32,devr1n33,devr1n23,devr1n22" --db-server="10.3.1.33" --db-name=devops --db-user=root  --db-pass=password  --node-type="cinder" --env-file="grizzly-devr1n32" --ssh-user=root --ssh-password=test4pass
#knife node upgrade --new-version="1.0.2" --repo-url="http://172.16.1.32/openstack/1.0.2" --roles-list="ROLE[AAA],role[BBB],role[CCC],role[DDD]" --nodes-list="devr1n32,devr1n33,devr1n23,devr1n22" --db-server="10.3.1.33" --db-name=devops --db-user=root  --db-pass=password  --node-type="cinder" --component-name=keystone --env-file="grizzly-devr1n32" --ssh-user=root --ssh-password=test4pass
# node-type = [ cinder | compute | controller  ]
# component-name = [ keystone | glance | controller] 
# Note: If you input the parameter 'component-name' ,then you do not need input parameter 'node-type'.
###

require 'chef/knife'
#require 'chef/couchdbupgrade'
#require 'optparse'
require 'rubygems'
require 'json'
require 'mysql'

module MyUpgradeNamespace
 class NodeUpgrade < Chef::Knife

  banner "knife node upgrade (options)"

  deps do
    require 'net/ssh'
    require 'net/ssh/multi'
    require 'readline'
    require 'chef/search/query'
    require 'chef/knife/search'
    require 'chef/mixin/command'
  end

  option :new_version,
    :long => "--new-version openstack-new-version",
    :description => "The new role version number."

  option :repo_url,
    :long => "--repo-url openstack-new-repo",
    :description => "The new openstack repository URL ."

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

  option :component_name,
    :long => "--component-name component-name",
    :description => "The openstack component name."

  option :node_type,
    :long => "--node-type node-type",
    :description => "The node type of upgrade node.[ cinder | compute | controller  ]"

  option :env_file,
    :long => "--env-file  environment-file",
    :description => "The environment json filename."

  option :ssh_user,
    :short => "-x USERNAME",
    :long => "--ssh-user USERNAME",
    :description => "The ssh username"

  option :ssh_password,
    :short => "-P PASSWORD",
    :long => "--ssh-password PASSWORD",
    :description => "The ssh password"

  def get_parameters
    if config[:new_version]
      $versionvalue = config[:new_version]
      puts "versionvalue = #{$versionvalue}"
    end
    if config[:repo_url]
      $repovalue = config[:repo_url]
      puts "repovalue = #{$repovalue}"
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
    if config[:component_name]
      $componentname = config[:component_name]
      puts "componentname = #{$componentname}"
    end
    if config[:db_pass]
      $dbpass = config[:db_pass]
      puts "dbpass = #{$dbpass}"
    end
    if config[:node_type]
      $nodetype = config[:node_type]
      puts "nodetype = #{$nodetype}"
    end
    if config[:env_file]
      $envfilename = config[:env_file]
      puts "envfilename = #{$envfilename}"
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
    #allroles.each do |role|
    allroles.split(",").each do |role|
      $roles_list += role + ","
    end
    $roles_list = $roles_list.chop
  end

  def get_new_version_roles(allroles,new_version)
    $new_roles_list = ""
    #allroles.each do |role|
    allroles.split(",").each do |role|
      new_role = role.gsub("]","-#{new_version}]")
      $new_roles_list += new_role + ","
    end
    $new_roles_list = $new_roles_list.chop
    #puts  $new_roles_list
  end

  def generate_new_repo(node,version,repourl)

    file = File.new("/tmp/openstack_#{node}.repo","w+")
    file.puts "[noarch_#{version}]"
    file.puts "name=openstack_noarch_#{version}"
    file.puts "baseurl=#{repourl}/noarch/"
    file.puts "enabled=1"
    file.puts "gpgcheck=0"
    file.puts "\n"
    file.puts "[x86_64_#{version}]"
    file.puts "name=openstack_x86_64_#{version}"
    file.puts "baseurl=#{repourl}/x86_64/"
    file.puts "enabled=1"
    file.puts "gpgcheck=0"
    file.puts "\n"
    file.puts "[patch_#{version}]"
    file.puts "name=openstack-patch-#{version}"
    file.puts "baseurl=#{repourl}/patch/"
    file.puts "enabled=1"
    file.puts "gpgcheck=0"
    file.close

  end

  def upgrade_component(node,action,component)
    puts "node = #{node}, action = #{action} , component = #{component}"
    username=$sshuser
    password=""

    case action
      when "yum" :
        begin
          ssh = Net::SSH.start(node, username, :password => password) do |ssh|
            result = ssh.exec!("yum clean all")
          end
         #system "scp /tmp/openstack_#{node}.repo root@#{node}:/etc/yum.repos.d/openstack-#{node}.repo 1>/dev/null 2>&1"
       end
      when "backup" :
        begin
          backup_former_repo = "curr=`date +%Y%m%d%H%M%S` ; mkdir -p /etc/yum.repos.d/$curr ; mv /etc/yum.repos.d/openstack* /etc/yum.repos.d/$curr/. ; mv /etc/yum.repos.d/Open* /etc/yum.repos.d/$curr/."
          ssh = Net::SSH.start(node, username, :password => password) do |ssh|
            result = ssh.exec!(backup_former_repo)
          end
          case component
            when "keystone"
              begin
                puts "backup => #{component}"
                backup_command = "if [ -d /tmp/keystone ] ; then rm -rf /tmp/keystone ; mkdir -p /tmp/keystone ; cp -Rp /etc/keystone/* /tmp/keystone/.  ; else mkdir -p /tmp/keystone ; cp -Rp /etc/keystone/* /tmp/keystone/. ; fi"
                ssh = Net::SSH.start(node, username, :password => password) do |ssh|
                  result = ssh.exec!(backup_command)
                end
              end
            when "glance"
              begin
                puts "backup => #{component}"
                backup_command = "if [ -d /tmp/glance ] ; then rm -rf /tmp/glance ; mkdir -p /tmp/glance ; cp -Rp /etc/glance/* /tmp/glance/.  ; else mkdir -p /tmp/glance ; cp -Rp /etc/glance/* /tmp/glance/. ; fi"
                ssh = Net::SSH.start(node, username, :password => password) do |ssh|
                  result = ssh.exec!(backup_command)
                end
              end
            when "controller"
              begin
                puts "backup => #{component}"
                backup_command = " if [ -d /tmp/nova ] ; then rm -rf /tmp/nova ; mkdir -p /tmp/nova ; cp -Rp /etc/nova/* /tmp/nova/. ; else mkdir -p /tmp/nova ; cp -Rp /etc/nova/* /tmp/nova/. ; fi" 
                ssh = Net::SSH.start(node, username, :password => password) do |ssh|
                  result = ssh.exec!(backup_command)
                end
              end
          #case component end
          end
        end
      when "uninstall" :
        begin
          case component
            when "keystone"
              begin
                puts "uninstall => #{component}"
                uninstall_command = "service openstack-keystone stop ; yum remove -y openstack-keystone ; rm -rf /var/log/keystone"
                ssh = Net::SSH.start(node, username, :password => password) do |ssh|
                  result = ssh.exec!(uninstall_command)
                end
              end
            when "glance"
              begin
                puts "uninstall => #{component}"
                uninstall_command = "service openstack-glance-api stop ; service openstack-glance-registry stop ; yum remove -y openstack-glance ; rm -rf /var/log/glance"
                ssh = Net::SSH.start(node, username, :password => password) do |ssh|
                  result = ssh.exec!(uninstall_command)
                end
              end
            when "controller"
              begin
                puts "uninstall => #{component}"
                uninstall_command = " service openstack-nova-cert stop ;service openstack-nova-api stop ; service openstack-nova-conductor stop ;service openstack-nova-scheduler stop ;  service openstack-nova-consoleauth stop ; service openstack-nova-vncproxy stop ; yum remove -y openstack-nova-scheduler ; yum remove -y openstack-nova-api ; yum remove -y openstack-nova-cert ; yum remove -y openstack-nova-conductor ; yum remove -y openstack-nova-console ; yum remove -y novnc ; rm -rf /var/log/nova/* "
                ssh = Net::SSH.start(node, username, :password => password) do |ssh|
                  result = ssh.exec!(uninstall_command)
                end
              end
          #case component end
          end
        end
      when "reinstall" :
        begin
         system "scp /tmp/openstack_#{node}.repo root@#{node}:/etc/yum.repos.d/openstack-#{node}.repo"
         ##system "scp /tmp/openstack_#{node}.repo root@#{node}:/etc/yum.repos.d/openstack-#{node}.repo 1>/dev/null 2>&1"
          case component
            when "keystone"
              begin
                puts "reinstall => #{component}"
                reinstall_command = "yum install -y openstack-keystone ; yum install -y ibm-simpletoken-authenticator-middleware ; service openstack-keystone restart service openstack-glance-api restart ; service openstack-glance-registry restart ; service openstack-nova-scheduler restart ; service openstack-nova-conductor restart ; service openstack-nova-api restart ; service openstack-nova-cert restart"
                ssh = Net::SSH.start(node, username, :password => password) do |ssh|
                  result = ssh.exec!(reinstall_command)
                end
              end
            when "glance"
              begin
                puts "reinstall => #{component}"
                reinstall_command = " yum install -y openstack-glance ; service openstack-keystone restart ; service openstack-glance-api restart ; service openstack-glance-registry restart ; yum install -y openstack-nova-scheduler ; yum install -y openstack-nova-conductor ; yum install -y openstack-nova-api ; yum install -y openstack-nova-cert ; service openstack-nova-scheduler restart ; service openstack-nova-conductor restart ; service openstack-nova-api restart ; service openstack-nova-cert restart"
                ssh = Net::SSH.start(node, username, :password => password) do |ssh|
                  result = ssh.exec!(reinstall_command)
                end
              end
            when "controller"
              begin
                puts "reinstall => #{component}"
                reinstall_command = "yum install -y openstack-nova-scheduler ; yum install -y openstack-nova-conductor ; yum install -y openstack-nova-api ; yum install -y openstack-nova-cert ; service openstack-nova-scheduler restart ; service openstack-nova-conductor restart ; service openstack-nova-api restart ; service openstack-nova-cert restart"
                ssh = Net::SSH.start(node, username, :password => password) do |ssh|
                  result = ssh.exec!(reinstall_command)
                end
              end
          #case component end
          end
        end
      when "restore" :
        begin
          case component
            when "keystone"
              begin
                puts "restore => #{component}"
                restore_command = " unalias -a ; cp -Rp /tmp/keystone/* /etc/keystone/. ;keystone-manage db sync; service openstack-keystone restart ; glance-manage db sync ; service openstack-glance-api restart ; service openstack-glance-registry restart ; nova-manage db sync ;  service openstack-nova-scheduler restart ; service openstack-nova-conductor restart ; service openstack-nova-api restart ; service openstack-nova-cert restart ; service openstack-nova-vncproxy restart ; service openstack-nova-api restart ; service openstack-nova-network restart ; service openstack-nova-compute restart "
                ssh = Net::SSH.start(node, username, :password => password) do |ssh|
                  result = ssh.exec!(restore_command)
                end
              end
            when "glance"
              begin
                puts "restore => #{component}"
                restore_command = " unalias -a ; cp -Rp /tmp/glance/* /etc/glance/. ; keystone-manage db sync; service openstack-keystone restart ; glance-manage db sync ; service openstack-glance-api restart ; service openstack-glance-registry restart ; nova-manage db sync ;  service openstack-nova-scheduler restart ; service openstack-nova-conductor restart ; service openstack-nova-api restart ; service openstack-nova-cert restart ; service openstack-nova-vncproxy restart ; service openstack-nova-api restart ; service openstack-nova-network restart ; service openstack-nova-compute restart "
                ssh = Net::SSH.start(node, username, :password => password) do |ssh|
                  result = ssh.exec!(restore_command)
                end
              end
            when "controller"
              begin
                puts "restore => #{component}"
                restore_command = " unalias -a ; cp -Rp /tmp/nova/* /etc/nova/. ; service openstack-keystone restart ; service openstack-glance-api restart ; service openstack-glance-registry restart ; nova-manage db sync ;  service openstack-nova-scheduler restart ; service openstack-nova-conductor restart ; service openstack-nova-api restart ; service openstack-nova-cert restart ; service openstack-nova-vncproxy restart ; service openstack-nova-api restart ; service openstack-nova-network restart ; service openstack-nova-compute restart "
                ssh = Net::SSH.start(node, username, :password => password) do |ssh|
                  result = ssh.exec!(restore_command)
                end
              end
          #case component end
          end
        end
    end
  end

  def ssh_command(node,action,node_type)
    username=$sshuser
    password=""

    case action
      when "yum" :
        begin
          ssh = Net::SSH.start(node, username, :password => password) do |ssh|
            result = ssh.exec!("yum clean all")
          end
         #upload new yum.repo file to remode machine
         #system "scp /tmp/openstack_#{node}.repo root@#{node}:/etc/yum.repos.d/openstack-#{node}.repo 1>/dev/null 2>&1"
       end
     when "backup" :
       begin
         backup_former_repo = "curr=`date +%Y%m%d%H%M%S` ; mkdir -p /etc/yum.repos.d/$curr ; mv /etc/yum.repos.d/openstack* /etc/yum.repos.d/$curr/. ; mv /etc/yum.repos.d/Open* /etc/yum.repos.d/$curr/."
         ssh = Net::SSH.start(node, username, :password => password) do |ssh|
            result = ssh.exec!(backup_former_repo)
         end
         case node_type
           when "cinder"
            begin
              cinder_backup_command = "mkdir -p /tmp/cinder ; if [ -f /etc/cinder/cinder.conf ] ; then cp /etc/cinder/cinder.conf /tmp/cinder/. ; fi ; cp -Rp /etc/tgt /tmp/. ; service openstack-cinder-api restart ; service openstack-cinder-volume restart "
              ssh = Net::SSH.start(node, username, :password => password) do |ssh|
                result = ssh.exec!(cinder_backup_command)
              end
            end
           when "compute"
            begin
              compute_backup_command = "mkdir -p /tmp/nova; if [ -f /etc/nova/nova.conf ] ; then cp -f /etc/nova/nova.conf /tmp/nova/. ; fi"
              ssh = Net::SSH.start(node, username, :password => password) do |ssh|
                result = ssh.exec!(compute_backup_command)
              end
            end
           when "controller"
            begin
              controller_backup_keystone_command = "if [ -d /tmp/keystone ] ; then rm -rf /tmp/keystone ; mkdir -p /tmp/keystone ; cp -Rp /etc/keystone/* /tmp/keystone/.  ; else mkdir -p /tmp/keystone ; cp -Rp /etc/keystone/* /tmp/keystone/. ; fi"
              controller_backup_glance_command = "if [ -d /tmp/glance ] ; then rm -rf /tmp/glance ; mkdir -p /tmp/glance ; cp -Rp /etc/glance/* /tmp/glance/.  ; else mkdir -p /tmp/glance ; cp -Rp /etc/glance/* /tmp/glance/. ; fi"
              controller_backup_nova_command = " if [ -d /tmp/nova ] ; then rm -rf /tmp/nova ; mkdir -p /tmp/nova ; cp -Rp /etc/nova/* /tmp/nova/. ; else mkdir -p /tmp/nova ; cp -Rp /etc/nova/* /tmp/nova/. ; fi" 
              ssh = Net::SSH.start(node, username, :password => password) do |ssh|
                result = ssh.exec!(controller_backup_keystone_command)
                result = ssh.exec!(controller_backup_glance_command)
                result = ssh.exec!(controller_backup_nova_command)
              end
            end
         end
       end
     when "install" :
       begin
         #upload new yum.repo file to remode machine
         system "scp /tmp/openstack_#{node}.repo root@#{node}:/etc/yum.repos.d/openstack-#{node}.repo 1>/dev/null 2>&1"
         case node_type
           when "cinder"
            begin
              cinder_install_command = "yum install -y openstack-cinder ; if [ ! -d /var/lib/cinder ] ; then mkdir -p /var/lib/cinder; elif [ -f /var/lib/cinder/cinder-volumes.img ] ; then vgremove cinder-volumes ; losetup -d `losetup -j /var/lib/cinder/cinder-volumes.img | awk -F ':' '{print $1}'` ; rm -rf /var/lib/cinder/cinder-volumes.img ; dd if=/dev/zero of=/var/lib/cinder/cinder-volumes.img bs=1M seek=40960 count=0; vgcreate cinder-volumes `losetup --show -f /var/lib/cinder/cinder-volumes.img` ; else dd if=/dev/zero of=/var/lib/cinder/cinder-volumes.img bs=1M seek=40960 count=0; vgcreate cinder-volumes `losetup --show -f /var/lib/cinder/cinder-volumes.img`; fi  ; cp -f /tmp/tgt /etc/. ; service tgtd restart ; service iscsi restart ; service openstack-cinder-api restart ; service openstack-cinder-scheduler restart ; service openstack-cinder-volume restart "
              ssh = Net::SSH.start(node, username, :password => password) do |ssh|
                result = ssh.exec!(cinder_install_command)
              end
            end
           when "compute"
            begin
              compute_install_command = "yum install -y openstack-nova-compute ; yum install -y openstack-nova-network ; yum install -y openstack-nova-api ; service openstack-nova-api restart ; service openstack-nova-network restart ; service openstack-nova-compute restart"
              ssh = Net::SSH.start(node, username, :password => password) do |ssh|
                result = ssh.exec!(compute_install_command)
              end
            end
           when "controller"
            begin
             controller_install_command = "yum install -y openstack-keystone ; yum install -y ibm-simpletoken-authenticator-middleware ; service openstack-keystone restart ; yum install -y openstack-glance ; service openstack-glance-api restart ; service openstack-glance-registry restart ; yum install -y openstack-nova-scheduler ; yum install -y openstack-nova-conductor ; yum install -y openstack-nova-api ; yum install -y openstack-nova-cert ; service openstack-nova-scheduler restart ; service openstack-nova-conductor restart ; service openstack-nova-api restart ; service openstack-nova-cert restart"
              ssh = Net::SSH.start(node, username, :password => password) do |ssh|
                result = ssh.exec!(controller_install_command)
              end
            end
         end
       end
     when "uninstall" :
       begin
         case node_type
           when "cinder"
            begin
              cinder_uninstall_command = " service openstack-cinder-api stop ; service openstack-cinder-volume stop ; service openstack-cinder-scheduler stop ;yum remove -y openstack-cinder-* ; cd /etc/yum.repos.d; ls *.repo | egrep -v \"rbel|rhel|local\" | xargs rm -rf ;if [ -f /var/lib/cinder/cinder-volumes.img ] ; then vgremove cinder-volumes ; fi ; losetup -d `losetup -a | awk '{if(substr($3,2,length($3)-2) == \"/var/lib/cinder/cinder-volumes.img\") printf(\"%s\\n\",substr($1,1,length($1)-1))}'` ; rm -rf /etc/cinder ; rm -rf /var/log/cinder "
              ssh = Net::SSH.start(node, username, :password => password) do |ssh|
                result = ssh.exec!(cinder_uninstall_command)
              end
            end
           when "compute"
            begin
              compute_uninstall_command = " service openstack-nova-api stop ; service openstack-nova-compute stop ; service openstack-nova-network ; yum remove -y openstack-nova-compute ; yum remove -y openstack-nova-network ; yum remove -y openstack-nova-api ; yum remove -y openstack-nova-common ; yum remove -y python-nova ; rm -rf /var/log/nova/* ; rm -rf /var/lib/nova/instances/* ; rm -rf /var/log/nova ; cd /etc/yum.repos.d;ls *.repo | egrep -v \"rbel|rhel|local\" | xargs rm -rf "
              ssh = Net::SSH.start(node, username, :password => password) do |ssh|
                result = ssh.exec!(compute_uninstall_command)
              end
            end
           when "controller"
            begin
              controller_uninstall_command = "service openstack-keystone stop ; yum remove -y openstack-keystone ; rm -rf /var/log/keystone ;service openstack-glance-api stop ; service openstack-glance-registry stop ; yum remove -y openstack-glance ; rm -rf /var/log/glance ; service openstack-nova-cert stop ;service openstack-nova-api stop ; service openstack-nova-conductor stop ;service openstack-nova-scheduler stop ;  service openstack-nova-consoleauth stop ; service openstack-nova-vncproxy stop ; yum remove -y openstack-nova-scheduler ; yum remove -y openstack-nova-api ; yum remove -y openstack-nova-cert ; yum remove -y openstack-nova-conductor ; yum remove -y openstack-nova-console ; yum remove -y novnc ; rm -rf /var/log/nova/* "
              ssh = Net::SSH.start(node, username, :password => password) do |ssh|
                result = ssh.exec!(controller_uninstall_command)
              end
            end
         end
       end
     when "restore" :
       begin
         case node_type
           when "cinder"
            begin
              cinder_restore_command = "unalias -a ; cp -f /tmp/cinder/cinder.conf /etc/cinder/. ; cp -f /tmp/tgt /etc/. ; echo \"include /var/lib/cinder/volumes/*\" >/etc/tgt/conf.d/cinder.conf ; service tgtd restart ; service iscsi restart ; service openstack-cinder-api restart ; service openstack-cinder-scheduler restart ; service openstack-cinder-volume restart "
              ssh = Net::SSH.start(node, username, :password => password) do |ssh|
                result = ssh.exec!(cinder_restore_command)
              end
            end
           when "compute"
            begin
              compute_restore_command = " unalias -a;cp -f /tmp/nova/nova.conf /etc/nova/. ; service openstack-nova-api restart ; service openstack-nova-network restart ; service openstack-nova-compute restart "
              ssh = Net::SSH.start(node, username, :password => password) do |ssh|
                result = ssh.exec!(compute_restore_command)
              end
            end
           when "controller"
            begin
              controller_restore_command = " unalias -a ; cp -Rp /tmp/keystone/* /etc/keystone/. ; cp -Rp /tmp/glance/* /etc/glance/. ; cp -Rp /tmp/nova/* /etc/nova/. ; keystone-manage db sync; service openstack-keystone restart ; glance-manage db sync ; service openstack-glance-api restart ; service openstack-glance-registry restart ; nova-manage db sync ;  service openstack-nova-scheduler restart ; service openstack-nova-conductor restart ; service openstack-nova-api restart ; service openstack-nova-cert restart ; service openstack-nova-vncproxy restart ; service openstack-nova-api restart ; service openstack-nova-network restart ; service openstack-nova-compute restart "
              ssh = Net::SSH.start(node, username, :password => password) do |ssh|
                result = ssh.exec!(controller_restore_command)
              end
            end
         end
       end 
    #case-end
    end
  end

  def get_currdate
    now = Time.now

    if now.month < 10
      month = 0.to_s.concat(now.month.to_s)
    else
      month = now.month.to_s
    end
    if now.day < 10
      day = 0.to_s.concat(now.day.to_s)
    else
      day = now.day.to_s
    end

    now.year.to_s.concat("-").concat(month).concat("-").concat(day)
  end 

  def get_currtime
    now = Time.now

    if now.hour < 10
      myhour = 0.to_s.concat(now.hour.to_s)
    else
      myhour = now.hour.to_s
    end
    if now.min < 10
      myminu = 0.to_s.concat(now.min.to_s)
    else
      myminu = now.min.to_s
    end

    if now.sec < 10
      mysec = 0.to_s.concat(now.sec.to_s)
    else
      mysec = now.sec.to_s
    end

    myhour.concat(":").concat(myminu).concat(":").concat(mysec)
  end

  def judge_table_exist?(db_name,table_name)
    sql = "show table status from #{db_name} like '#{table_name}'"
    res = $dbh.query(sql)
    #puts sql
    jug_val=""
    res.each_hash do |val|
      #puts val['Name']
      jug_val = val['Name']
    end
    if jug_val == ""
      #need create table
      puts "Error: The talbe => '#{table_name}' doesn't existed." 
      if not res.nil? 
        res.free
      end
      exit 1
    end
    if not res.nil? 
      res.free
    end
  end

  def judge_auto_increment_value(db_name,table_name)
    auto_increment = 0
    sql = "show table status from #{db_name} like '#{table_name}'"
    res = $dbh.query(sql)
    res.each_hash do |row|
      #puts "row Auto_increment = #{row['Auto_increment']}"
    auto_increment = row['Auto_increment']
  end
    if not res.nil? 
      res.free
    end
    auto_increment 
  end

  def select_data_from_table(db_name,query_sql)
    hab = Array.new
    row_count = 0
    ##res return all records.
    $dbh.query("use #{db_name}")
    res = $dbh.query(query_sql)
    res.each_hash do |row|
      hab[row_count] = row
      puts hab
      row_count = row_count + 1
    end
    if not res.nil? 
      res.free
    end
    return hab
  end

  def insert_data_into_table(db_name,insert_sql)
    puts "insert_sql = #{insert_sql}" 
    $dbh.query("use #{db_name}")
    res = $dbh.query(insert_sql)
    $dbh.query("commit")
    if not res.nil? 
      res.free
    end
  end

  def update_table(db_name,update_sql)
    $dbh.query("use #{db_name}")
    puts "update_sql = #{update_sql}"
    res = $dbh.query(update_sql)
    $dbh.query("commit")
    if not res.nil? 
      res.free
    end
  end

  def run

    if config[:nodes_list].nil?
      system " knife node upgrade --help "
      ui.fatal("You must specify correct command-line parameters!")
      exit 1
    end

    if config[:roles_list].nil? || config[:new_version].nil? || config[:repo_url].nil?
      system " knife node upgrade --help "
      ui.fatal("You must specify correct command-line parameters!")
      exit 1
    end

    get_parameters

    get_roles_list($rolesvalue)
    get_new_version_roles($rolesvalue,$versionvalue)

    puts $roles_list
    puts $new_roles_list
   
    #coonnect_to_database
    $dbh = Mysql.real_connect($dbserver,$dbuser,$dbpass,$dbname)
    

    $nodesvalue.split(",").each do |node| 

      puts "node ==============> #{node}"

      # generate yum repos files for #{node}
      generate_new_repo(node,$versionvalue,$repovalue)

      begin_date = get_currdate
      begin_time = get_currtime

      #insert into openstack component information to table OPENSTACK_INSTANCE.
      judge_table_exist?($dbname,"openstack_instance") 
      auto_inc_val = 0
      auto_inc_val = judge_auto_increment_value($dbname,"openstack_instance")
      if config[:node_type].nil?
        insert_openstack_instance_sql = "insert into openstack_instance values(#{auto_inc_val},'#{$componentname}','#{$versionvalue}',NULL)"
        insert_data_into_table($dbname,insert_openstack_instance_sql)
      else
        insert_openstack_instance_sql = "insert into openstack_instance values(#{auto_inc_val},'#{$nodetype}','#{$versionvalue}',NULL)"
        insert_data_into_table($dbname,insert_openstack_instance_sql)
      end
      
      #insert into repo information to table INSTALL_REPO.
      judge_table_exist?($dbname,"install_repo") 
      auto_inc_val = 0
      auto_inc_val = judge_auto_increment_value($dbname,"install_repo")
      insert_install_repo_sql = "insert into install_repo values(#{auto_inc_val},'#{$repovalue}','#{$versionvalue}')"
      insert_data_into_table($dbname,insert_install_repo_sql)
##########################=begin
      if config[:component_name].nil?
        # to backup all related data on remote node
        puts "To begin to backup #{$nodetype} node #=> #{node}"
        ssh_command(node,"backup",$nodetype)
        puts "To end to backup #{$nodetype} node #=> #{node}"

        # to uninstall all related components
        puts "To begin to uninstall #{$nodetype} node #=> #{node}"
        ssh_command(node,"uninstall",$nodetype)
        puts "To end to uninstall #{$nodetype} node #=> #{node}"

        # to re-install new version components
        puts "To begin to re-install #{$nodetype} node #=> #{node}"
        ssh_command(node,"yum",$nodetype)
        ssh_command(node,"install",$nodetype)
        puts "To end to re-install #{$nodetype} node #=> #{node}"

        # to restore all related data on remote node
        puts "To begin to restore #{$nodetype} node #=> #{node}"
        ssh_command(node,"restore",$nodetype)
        puts "To end to restore #{$nodetype} node #=> #{node}"
      else
        ######upgrade_component(node,action,component)
        # to backup all related data on remote node
        puts "To begin to backup #{$componentname} node #=> #{node}"
        upgrade_component(node,"backup",$componentname)
        puts "To end to backup #{$componentname} node #=> #{node}"

        # to uninstall all related components
        puts "To begin to uninstall #{$componentname} node #=> #{node}"
        upgrade_component(node,"uninstall",$componentname)
        puts "To end to uninstall #{$componentname} node #=> #{node}"

        # to re-install new version components
        puts "To begin to re-install #{$componentname} node #=> #{node}"
        upgrade_component(node,"yum",$componentname)
        upgrade_component(node,"reinstall",$componentname)

        #system "knife bootstrap #{node} -x #{$sshuser} -P #{$sshpass} -r '#{$roles_list}' -E grizzly-devr1n32 1>/tmp/#{node}-#{$nodetype}.bootstrap 2>&1"
        #system "knife bootstrap #{node} -x #{$sshuser} -P #{$sshpass} -r '#{$roles_list}' -E grizzly-devr1n32" 
        #system "knife bootstrap #{node} -x #{$sshuser} -P #{$sshpass} -r '#{$roles_list}' -E #{$envfilename}" 

        puts "To end to re-install #{$componentname} node #=> #{node}"

        # to restore all related data on remote node
        puts "To begin to restore #{$componentname} node #=> #{node}"
        upgrade_component(node,"restore",$componentname)
        puts "To end to restore #{$componentname} node #=> #{node}"
      end
##########################=end
      end_date = get_currdate
      end_time = get_currtime
      curr_start_time = begin_date.concat(" ").concat(begin_time)
      curr_end_time = end_date.concat(" ").concat(end_time)
      #puts "curr_start_time = #{curr_start_time}"
      #puts "curr_end_time = #{curr_end_time}"
      #insert upgrade result data into table NODE_ACTION_HISTORY
      auto_inc_val = 0
      judge_table_exist?($dbname,"node_action_history") 
      auto_inc_val = judge_auto_increment_value($dbname,"node_action_history")
      result_data = Array.new
      result_data = select_data_from_table($dbname,"select node_id,hostname from node_config where hostname = '#{node}' or install_ip = '#{node}'")
      curr_node_id = result_data[0]['node_id']
      curr_node_name = result_data[0]['hostname']
      result_data = []
      if config[:node_type].nil?
        result_data = select_data_from_table($dbname,"select openstack_instance_id, build_number from current_node_openstack_instance where openstack_instance_name='#{$componentname}' and node_id = #{curr_node_id} ")
        curr_openstack_instance_id = result_data[0]['openstack_instance_id']
        curr_from_build_name = result_data[0]['build_number']
        update_table($dbname,"update current_node_openstack_instance set build_number = '#{$versionvalue}' where node_id = #{curr_node_id} and openstack_instance_name= '#{$componentname}' ")

        insert_node_action_history_sql = "insert into node_action_history values(#{auto_inc_val},#{curr_node_id},'#{curr_node_name}',#{curr_openstack_instance_id},'#{$componentname}','#{$rolesvalue}','upgrade','#{curr_from_build_name}','#{$versionvalue}','success','#{curr_start_time}','#{curr_end_time}') "
        insert_data_into_table($dbname,insert_node_action_history_sql)
      else
        result_data = select_data_from_table($dbname,"select openstack_instance_id, build_number from current_node_openstack_instance where openstack_instance_name='#{$nodetype}' and node_id = #{curr_node_id} ")
        curr_openstack_instance_id = result_data[0]['openstack_instance_id']
        curr_from_build_name = result_data[0]['build_number']
        update_table($dbname,"update current_node_openstack_instance set build_number = '#{$versionvalue}' where node_id = #{curr_node_id} and openstack_instance_name= '#{$nodetype}' ")

        insert_node_action_history_sql = "insert into node_action_history values(#{auto_inc_val},#{curr_node_id},'#{curr_node_name}',#{curr_openstack_instance_id},'#{$nodetype}','#{$rolesvalue}','upgrade','#{curr_from_build_name}','#{$versionvalue}','success','#{curr_start_time}','#{curr_end_time}') "
        insert_data_into_table($dbname,insert_node_action_history_sql)
      end
        
    #do-individual-node-end
    end
    
    #close database connection
    $dbh.close 
  #run-end
  end
 #class-end
 end
#module-end
end
