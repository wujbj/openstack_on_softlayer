module RCB
  def create_db_and_user(db, db_name, username, pw)
    db_info = nil
    case db
      when "mysql"
        Chef::Log.debug("Create #{db_name}, user: #{username}, password: #{pw}")
        mysql_info = get_settings_by_role("mysql-master", "mysql")
        if mysql_info.nil?
            mysql_info = get_settings_by_role("os-ops-database", "mysql")
        end
        connection_info = {:host => mysql_info["bind_address"], :username => "root", :password => mysql_info["server_root_password"]}

        # create database
        sql = "create database #{db_name};"
        Chef::Log.debug("mysql -h #{connection_info[:host]} -u #{connection_info[:username]} -p\"#{connection_info[:password]}\" -e '#{sql}'")
        execute "create mysql db #{db_name}" do
          command "mysql -h #{connection_info[:host]} -u #{connection_info[:username]} -p\"#{connection_info[:password]}\" -e '#{sql}'"
          action :run
          not_if "mysql -h #{connection_info[:host]} -u #{connection_info[:username]} -p\"#{connection_info[:password]}\" -e 'show databases;' | grep #{db_name}"
        end
#        mysql_database "create #{db_name} database" do
#          connection connection_info
#          database_name db_name
#          action :create
#        end

        # create user
        check_sql = "select User,host from mysql.user where User='#{username}' AND host = '#{connection_info[:host]}'"
        sql = "create user \'#{username}\'@\'#{connection_info[:host]}\' identified by \'#{pw}\';"
        Chef::Log.debug("mysql -h #{connection_info[:host]} -u #{connection_info[:username]} -p\"#{connection_info[:password]}\" -e \"#{sql}\"")
        execute "create mysql user #{username}" do
          command "mysql -h #{connection_info[:host]} -u #{connection_info[:username]} -p\"#{connection_info[:password]}\" -e \"#{sql}\""
          action :run
          not_if "mysql -h #{connection_info[:host]} -u #{connection_info[:username]} -p\"#{connection_info[:password]}\" -e \"#{check_sql};\" | grep #{username}"
        end
#        mysql_database_user username do
#          connection connection_info
#          password pw
#          action :create
#        end

        # grant privs to user
        sql = "GRANT all ON #{db_name}.* TO '#{username}'@'%' IDENTIFIED BY '#{pw}';"
        Chef::Log.debug("mysql -h #{connection_info[:host]} -u #{connection_info[:username]} -p\"#{connection_info[:password]}\" -e \"#{sql}\"")
        execute "grant mysql user #{username} to db #{db_name}" do
          command "mysql -h #{connection_info[:host]} -u #{connection_info[:username]} -p\"#{connection_info[:password]}\" -e \"#{sql}\""
          action :run
        end
#        mysql_database_user username do
#          connection connection_info
#          password pw
#          database_name db_name
#          host '%'
#          privileges [:all]
#          action :grant
#        end
        db_info = mysql_info
    end
    db_info
  end

  def get_db_ipaddrss(db_type)
    ip_address = ""
    case db_type
      when "mysql"
        mysql_info = get_access_endpoint("mysql-master", "mysql", "db")
        ip_address = mysql_info["host"]
      when "db2"
        db2_info = get_access_endpoint("db2", "db2", "db")
        if db2_info.nil?
            db2_info = get_access_endpoint("os-ops-database", "db2", "db")
        end
        ip_address = db2_info["host"]
    end
    ip_address
  end



  def get_db_connection(db_type, db_name, username, pw)
    db_connection = nil
    case db_type
      when "mysql"
        mysql_info = get_access_endpoint("os-ops-database", "mysql", "db")
        db_connection = "mysql://#{username}:#{pw}@#{mysql_info["host"]}/#{db_name}"
      when "db2"
        db2_info = get_access_endpoint("os-ops-database", "db2", "db")
        if node['openstack']['db']['cluster']
          db2_info['host'] = node['openstack']['db']['vip']
        end
        db_connection = "ibm_db_sa://#{username}:#{pw}@#{db2_info["host"]}:#{db2_info["port"]}/#{node['openstack']['db']['db2_name']}"
    end
    db_connection
  end

  def secret bag_name, index
    if node["openstack"]["developer_mode"]
       return index
    end 
    key_path = node["openstack"]["secret"]["key_path"]
    ::Chef::Log.info "Loading encrypted databag #{bag_name}.#{index} using key at #{key_path}"
    secret = ::Chef::EncryptedDataBagItem.load_secret key_path
    ::Chef::EncryptedDataBagItem.load(bag_name, index, secret)[index]
  end 

  # Ease-of-use/standardization routine that returns a service password
  #   # for a named OpenStack service. Note that databases are named
  #     # after the OpenStack project nickname, like "nova" or "glance"
  def service_password service
    bag = node["openstack"]["secret"]["service_passwords_data_bag"]
    secret bag, service
  end 
  
  # Ease-of-use/standardization routine that returns a database password
  # for a named OpenStack database. Note that databases are named
  # after the OpenStack project nickname, like "nova" or "glance"
  def db_password service
    bag = node["openstack"]["secret"]["db_passwords_data_bag"]
    secret bag, service
  end 

  def db service
    node['openstack']['db'][service]
    rescue
      nil 
  end 

  def db_uri service, user, pass
    info = db(service)
    if info
      host = info['host']
      port = info['port'].to_s
      type = info['db_type']
      name = info['db_name']
      if type == "pgsql"
        # Normalize to the SQLAlchemy standard db type identifier
        type = "postgresql"
      end 
      case type
      when "mysql", "postgresql"
          result = "#{type}://#{user}:#{pass}@#{host}:#{port}/#{name}"
      when "sqlite"
          # SQLite uses filepaths not db name
          path = info['path']
          result = "sqlite://#{path}"
      when "db2"
          result = "ibm_db_sa://#{user}:#{pass}@#{host}:#{port}/#{node['openstack']['db']['db2_name']}"
      end 
    end 
  end
end
