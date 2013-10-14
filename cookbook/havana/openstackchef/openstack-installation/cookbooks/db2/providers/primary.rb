action :setup do
    params = Hash.new()
    attributes = ['db_name', 'standby_host', 'primary_host', 'standby_port', 'primary_port']
    attributes.each do |attribute|
        if new_resource.respond_to?(attribute)
            params[attribute] = new_resource.send(attribute.to_sym) unless new_resource.send(attribute.to_sym).nil?
        end
    end

    db_name = new_resource.db_name
    instance_username = node['db2']['instance_username']
    instance_home_dir = node['db2']['instance_home_dir']
    params['instance_username'] = instance_username
    backup_dir = "#{instance_home_dir}/backup/#{db_name}"
    params['backup_dir'] = backup_dir

    directory "#{backup_dir}" do
        owner instance_username
        group instance_username
        recursive true
        mode "0755"
        action :create
    end

    sql_path = "#{instance_home_dir}/primary-#{db_name}.sql"
    template "#{sql_path}" do
        cookbook 'db2'
        source "primary.sql.erb"
        owner instance_username
        group instance_username
        mode "0644"
        variables(
            "name" => new_resource.name,
            "params" => params
        )
    end

    execute "setting up DB2 primary" do
        command "su - #{instance_username} -c 'db2 -v -f #{sql_path}'"

        ## the database db_name is exist and is not HA
        only_if "su - #{instance_username} -c \"(db2 'list database directory' | grep -i -w '#{db_name}') \
                && (! db2pd -hadr -db #{db_name})\""
        timeout 10000
    end
end
