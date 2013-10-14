action :create do

    db_name = new_resource.db_name
    db_schema = new_resource.db_schema
    instance_username = node['db2']['instance_username']
    
    execute "create schema(#{db_schema}) on database(#{db_name})" do
        command "su - #{instance_username} -c \"(db2 'connect to #{db_name}') && (db2 'create schema #{db_schema}')\""

        ## the database db_name is exist and is not standby
        only_if "su - #{instance_username} -c \"(db2 'list database directory' | grep -i -w '#{db_name}') \
                && (! db2pd -hadr -db #{db_name} | grep -w -q 'HADR_ROLE = STANDBY')\""

        ## the db_schema is not exist on db_name
        not_if "su - #{instance_username} -c \"(db2 'connect to #{db_name}') \
                && (! db2 \\\"select SCHEMANAME from SYSCAT.SCHEMATA where SCHEMANAME = '#{db_schema.upcase}'\\\")\""
    end

end
