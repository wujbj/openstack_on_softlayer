# Description

Install/Configure DB2

## Recipes

* db2::install  Install DB2

* db2::restart  Restart DB2 instance

* db2::odbc_install  Install DB2 ODBC CLI

* db2::database Create a DB2 database

* db2:user Create a DB2 database user

* db2:primary Setup DB2 HA primary

* db2:standby Setup DB2 HA standby

## Usage

### Install db2

* Simple way:

```
db2 "install db2" do
    db2_url node['db2']['url']
    action :install
end

```

* Full parameters

```
db2 "install db2" do
    url node['db2']['url']
    port 50000
    fcm_port 60000
    max_logical_nodes 4
    install_dir "/opt/ibm/db2/v10.1"
    instance_name "db2inst1"
    instance_type "ese"
    instance_home_dir "/home/db2inst1"
    instance_username "db2inst1"
    instance_password "passw0rd"
    fenced_username "db2fenc1"
    fenced_password "passw0rd"
    das_username "db2das1"
    req_packages ["libaio", "dapl", "sg3_utils"]
    action :install
end
```

### Install DB2 ODBC Driver

* Simple way

```
db2_odbc "install db2 odbc driver" do
    db2_odbc_url node['db2']['odbc_url']
    action :install
end
```

* Full parameters

```
db2_odbc "install db2 odbc driver" do
    db2_odbc_url node['db2']['odbc_url']
    db2_odbc_install_dir "/opt/ibm"
    db2_odbc_req_packages ["python-sqlalchemy", "python-migrate", "python-ibm-db", "python-ibm-db-sa"]
    action :install
end
```

### Create DB2 database

```
db2_database "create database #{node['db2']['db_name']}" do
    db_name node['db2']['db_name']
    action :create
end
```

### Create a database user

By default, this recipe will not create shema and the privileges is DBADM.

db2_user "create database user" do
    db_user     node['db2']['db_user']
    db_pass     node['db2']['db_pass']
    db_name     node['db2']['db_name']
    # privileges  'CONNECT,DATAACCESS'
    action :create
end

### Setup a database HA Primary node

```
db2_primary "setup DB2 primary" do
    db_name      node['db2']['db_name']
    primary_host node['db2']['primary_host']
    primary_port node['db2']['primary_port']
    standby_host node['db2']['standby_host']
    standby_port node['db2']['standby_port']
    action :setup
end
```

The Primary node VIP transfer section can be found in `db2::primary` recipe.

### Setup a database HA Standby node

```
db2_standby "setup DB2 standby" do
    db_name      node['db2']['db_name']
    primary_host node['db2']['primary_host']
    primary_port node['db2']['primary_port']
    standby_host node['db2']['standby_host']
    standby_port node['db2']['standby_port']
    action :setup
end
```

The Standby node VIP transfer section can be found in `db2::standby` recipe.
