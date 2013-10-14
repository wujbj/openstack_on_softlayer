
action :install do

  puts '================================================================='
  puts 'please install db2-odbc.x86_64 rpm packages (zhiwchen@cn.ibm.com)'
  puts '================================================================='
  exit(1)

    if ::File.exists?("#{new_resource.odbc_install_dir}/odbc_cli")
        puts "\n======================================================="
        puts "DB2 ODBC driver was already installed"
        puts "Use `rm -rf #{new_resource.odbc_install_dir}/odbc_cli /etc/ld.so.conf.d/db2_odbc.conf` to uninstall"
        puts "======================================================="
    else
        params = Hash.new()
        attributes = ['odbc_install_dir']
        attributes.each do |attribute|
            if new_resource.respond_to?(attribute)
                params[attribute] = new_resource.send(attribute.to_sym) unless new_resource.send(attribute.to_sym).nil?
            end
        end

        new_resource.odbc_req_packages.each do |pkg|
            package pkg do
                action :install
                retries 5
                retry_delay 10
            end
        end

        #db2_dir = '/root/chef_db2'
        #directory "#{db2_dir}" do
        #    owner "root"
        #    group "root"
        #    mode "0755"
        #    recursive true
        #    action :create
        #end

        #db2_pkgname = new_resource.odbc_url.split('/').last.to_s
        #execute "Download db2 odbc package" do
        #    cwd db2_dir
        #    command "wget -O #{db2_pkgname} #{new_resource.odbc_url}"
        #end

        package node['db2']['odbc_packages']

        directory "#{new_resource.odbc_install_dir}" do
            owner "root"
            group "root"
            mode "0755"
            recursive true
            action :create
        end

        execute "Install db2" do
            #cwd db2_dir
            #command "tar -C #{new_resource.odbc_install_dir} -xf #{db2_pkgname}"
	    command "tar -C #{new_resource.odbc_install_dir} -xf /kits/db2-odbc-1.0/db2_v10.1fp2_linuxx64_odbc_cli.tar"

        end

        ldconf = '/etc/ld.so.conf.d/db2_odbc.conf'
        r = template "#{ldconf}" do
            cookbook 'db2'
            source "db2_odbc.conf.erb"
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
    end
end
