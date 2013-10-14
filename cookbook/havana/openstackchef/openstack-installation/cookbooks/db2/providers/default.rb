
action :install do

    if ::File.exists?(new_resource.install_dir)
        puts "\n======================================================="
        puts "DB2 was already installed"
        puts "Use `bash /root/chef_db2/db2_uninstall.sh` to uninstall"
        puts "======================================================="
    else
        params = Hash.new()
        attributes = ['port', 'fcm_port', 'max_logical_nodes', 'install_dir', 'instance_type', 'instance_username', 'instance_home_dir', 'instance_password', 'fenced_username', 'fenced_password', 'das_username', 'das_password']
        attributes.each do |attribute|
            if new_resource.respond_to?(attribute)
                params[attribute] = new_resource.send(attribute.to_sym) unless new_resource.send(attribute.to_sym).nil?
            end
        end

        new_resource.req_packages.each do |pkg|
            package pkg do
                action :install
                retries 5
                retry_delay 10
            end
        end

	# commented as part of merge
        db2_dir = '/root/chef_db2'
        #directory "#{db2_dir}" do
        #    recursive true
        #    action :delete
        #end

        directory "#{db2_dir}" do
            owner "root"
            group "root"
            mode "0755"
            recursive true
            action :create
        end

        #db2_pkgname = new_resource.url.split('/').last.to_s
        #execute "Download db2 package" do
        #    cwd db2_dir
        #    command "wget -O #{db2_pkgname} #{new_resource.url}"
        #end

        package node['db2']['packages']
        execute "extract_db2_files" do
          case node['db2']['install_dir']
          when "/opt/ibm/db2/v10.1"
            command "tar -xf /kits/db2_aese_10.1.2-1.0/db2_v10.1fp2_linuxx64_server.tar -C #{db2_dir}"
	    not_if do
              FileTest.directory?("#{db2_dir}/server/")
            end
	    when "/opt/ibm/db2/V9.7"
	      command "tar -xf /kits/db2_ese_9.7-1.0/DB2_ESE_97_Linux_x86-64.tar -C #{db2_dir}"
	    not_if do
              FileTest.directory?("#{db2_dir}/ese/")
            end
	  end
        end

        rsp_file = "#{db2_dir}/db2_install.rsp"
        r = template "#{rsp_file}" do
            cookbook 'db2'
            source "db2_install.rsp.erb"
            owner "root"
            group "root"
            mode "0644"
            variables(
                "name" => new_resource.name,
                "params" => params
            )
        end
        new_resource.updated_by_last_action(r.updated_by_last_action?)

        directory "#{new_resource.install_dir}" do
            owner "root"
            group "root"
            mode "0755"
            recursive true
            action :create
        end

        bash "Check db2 node hostname" do
            code <<-EOH
            if ! ping -c 1 $(hostname); then
                echo -e "127.0.0.1\t$(hostname)" >> /etc/hosts
            fi
            EOH
        end

        template "#{db2_dir}/db2_uninstall.sh" do
            cookbook 'db2'
            source "db2_uninstall.sh.erb"
            owner "root"
            group "root"
            mode "0644"
            variables(
                "name" => new_resource.name,
                "params" => params
            )
        end


	execute "Install db2" do
	  cwd db2_dir
  	  case node['db2']['install_dir']
	  when "/opt/ibm/db2/v10.1"
   	    command "./server/db2setup -l #{db2_dir}/db2_install.log -r #{rsp_file}"	  when "/opt/ibm/db2/V9.7"
            command "./ese/db2setup -l #{db2_dir}/db2_install.log -r #{rsp_file}"
	  end
        end	

        #execute "Install db2" do
        #    cwd db2_dir
        #    returns [0, 1]
        #    command "tar xf #{db2_pkgname} && ./$(ls -l . | awk '/^d/ {print $NF;exit;}')/db2setup -l #{db2_dir}/db2_install.log -r #{rsp_file}"
        #end

        ldconf = '/etc/ld.so.conf.d/db2.conf'
        r = template "#{ldconf}" do
            cookbook 'db2'
            source "db2.conf.erb"
            owner "root"
            group "root"
            mode "0644"
            variables(
                "name" => new_resource.name,
                "params" => params
            )
            # notifies :run, 'execute[ldconfig]', :immediately
        end
        new_resource.updated_by_last_action(r.updated_by_last_action?)

        execute "ldconfig" do
            command "ldconfig"
        end

        ## Add autostart after reboot
        bash "add autostart after reboot" do
            code <<-EOH
            if ! grep -q -w db2start /etc/rc.local; then
                echo "su - #{new_resource.instance_username} -c 'db2start'" >> /etc/rc.local
            fi
            EOH
        end

    end
end

action :restart do
    execute "stop db2 instance service" do
      command "su - #{new_resource.instance_username} -c 'db2stop'"
      ignore_failure true
    end

    execute "start db2 instance service" do
      command "su - #{new_resource.instance_username} -c 'db2start'"
      ignore_failure true
    end
end
