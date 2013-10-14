action :create do

    db_name = new_resource.db_name
    instance_username = node['db2']['instance_username']

    execute "create database(#{db_name})" do
        command "su - #{instance_username} -c \"db2 'create database #{db_name} AUTOMATIC STORAGE YES USING CODESET UTF-8 TERRITORY CN COLLATE USING SYSTEM PAGESIZE 8192'\""

        ## the database db_name is not exist and is not standby
        only_if "su - #{instance_username} -c \"(! db2 'list database directory' | grep -i -w '#{db_name}') \
                && (! db2pd -hadr -db #{db_name} | grep -w -q 'HADR_ROLE = STANDBY')\""

        timeout 10000

    end

end
