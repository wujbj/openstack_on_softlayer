action :create do

    db_user = new_resource.db_user
    db_pass = new_resource.db_pass
    db_name = new_resource.db_name
    # db_schema = new_resource.db_schema
    db_priv = new_resource.privileges
    instance_username = node['db2']['instance_username']
    
    user "create database user(#{db_user})" do
        username db_user
        supports :manage_home => true
        action :create
        not_if "id #{db_user}"
    end

    execute "set database user(#{db_user}) password" do
        command "echo #{db_pass} | passwd #{db_user} --stdin"
    end

    execute "grant privilege to user(#{db_user}) on database(#{db_name})" do
        command "su - #{instance_username} -c \"(db2 'connect to #{db_name}') \
                && (db2 'grant #{db_priv} on database to user #{db_user}') && (db2 'connect reset')\""

        ## the database db_name is exist and is not standby
        only_if "su - #{instance_username} -c \"(db2 'list database directory' | grep -i -w '#{db_name}') \
                && (! db2pd -hadr -db #{db_name} | grep -w -q 'HADR_ROLE = STANDBY')\""
    end

    # if ! db_schema.nil?
    #     execute "grant privilege to user(#{db_user}) on database(#{db_name}) and schema(#{db_schema})" do
    #         command "su - #{instance_username} -c \"(db2 'connect to #{db_name}') \
    #                 && (db2 'GRANT CREATEIN,DROPIN,ALTERIN ON SCHEMA #{db_schema} TO USER #{db_user}')\""

    #         ## the db_schema is exist on db_name
    #         only_if "su - #{instance_username} -c \"(db2 'connect to #{db_name}') \
    #                 && (db2 \\\"select SCHEMANAME from SYSCAT.SCHEMATA where SCHEMANAME = '#{db_schema.upcase}'\\\")\""
    #     end
    # end

end
