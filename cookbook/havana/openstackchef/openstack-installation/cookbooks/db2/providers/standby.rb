action :setup do
    params = Hash.new()
    attributes = ['db_name', 'standby_host', 'primary_host', 'standby_port', 'primary_port']
    attributes.each do |attribute|
        if new_resource.respond_to?(attribute)
            params[attribute] = new_resource.send(attribute.to_sym) unless new_resource.send(attribute.to_sym).nil?
        end
    end

    db_name = new_resource.db_name
    primary_host = new_resource.primary_host
    instance_password = node['db2']['instance_password']
    instance_username = node['db2']['instance_username']
    instance_home_dir = node['db2']['instance_home_dir']
    params['instance_username'] = instance_username
    backup_dir = "#{instance_home_dir}/backup"
    params['backup_dir'] = "#{backup_dir}/#{db_name}"

    package 'install sshpass for copying DB2 backup data' do
        package_name 'sshpass'
        action :install
    end

    execute "delete-remote-backup_dir" do
        command "sshpass -p#{instance_password} ssh -o StrictHostKeyChecking=no \
                #{instance_username}@#{primary_host} 'rm -rf #{backup_dir}'"
        action :nothing
    end

    execute "copy backup database file from Primary" do
        command "su - #{instance_username} -c 'sshpass -p#{instance_password} scp -r -o StrictHostKeyChecking=no #{instance_username}@#{primary_host}:#{backup_dir} ~'"
        not_if "su - #{instance_username} -c 'db2 list database directory | grep -i -w #{db_name}'"
        timeout 10000
    end

    sql_path = "#{instance_home_dir}/standby-#{db_name}.sql"
    template "#{sql_path}" do
        cookbook 'db2'
        source "standby.sql.erb"
        owner instance_username
        group instance_username
        mode "0644"
        variables(
            "name" => new_resource.name,
            "params" => params
        )
        # notifies :run, 'execute[delete-remote-backup_dir]', :delayed
    end

    execute "setting up DB2 standby" do
        command "su - #{instance_username} -c 'db2 -v -f #{sql_path}'"

        ## DB2 database db_name is exist
        not_if "su - #{instance_username} -c 'db2 list database directory | grep -i -w #{db_name}'"
        timeout 10000
    end
end
