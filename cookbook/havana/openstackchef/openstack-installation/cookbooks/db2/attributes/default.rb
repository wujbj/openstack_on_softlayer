# required option
default['db2']['url'] = "http://172.16.0.2/db2_10.1/v10.1fp2_linuxx64_server.tar.gz"
default['db2']['odbc_url'] = "http://172.16.0.2/db2_10.1/v10.1fp2_linuxx64_odbc_cli.tar.gz"
default['db2']['odbc_packages'] = "db2-odbc"

default['db2']['das_password'] = 'passw0rd'
default['db2']['instance_password'] = 'passw0rd'
default['db2']['fenced_password'] = 'passw0rd'

# default['db2']['db_name'] = "dbname"
# default['db2']['db_schema'] = "dbschema"
# default['db2']['db_user'] = "dbuser"
# default['db2']['db_pass'] = "passw0rd"
# 
# default['db2']['ha_vip'] = '172.16.1.242'
# default['db2']['primary_host'] = "172.16.1.25"
# default['db2']['standby_host'] = "172.16.1.26"
# default['db2']['primary_port'] = 10000
# default['db2']['standby_port'] = 10000

# optional options
default['db2']['port'] = 50000
default['db2']['fcm_port'] = 60000
default['db2']['max_logical_nodes'] = 4
default['db2']['install_dir'] = "/opt/ibm/db2/v10.1"
default['db2']['instance_type'] = "ESE"
default['db2']['instance_home_dir'] = "/home/db2inst1"
default['db2']['instance_username'] = "db2inst1"
default['db2']['fenced_username'] = "db2fenc1"
default['db2']['das_username'] = "db2das1"
default['db2']['req_packages'] = ["libaio", "dapl", "sg3_utils", "libibcm", "ibsim", "ibutils", "libcxgb3", "libipathverbs", "libibmad", "libibumad", "libipathverbs", "libmthca", "libnes", "rdma"]

default['db2']['odbc_install_dir'] = "/opt/ibm"
default['db2']['odbc_req_packages'] = ["python-sqlalchemy", "python-migrate", "python-ibm-db", "python-ibm-db-sa"]

if (node.name.include? 'tds' or node.name.include? 'utd')
  #default['db2']['url'] = "http://cwr01/yum/middleware/5Server/x86_64/DB2_ESE_97_Linux_x86-64.tar"
  default['db2']['packages'] = "db2_ese_9.7"
  default['db2']['install_dir'] = "/opt/ibm/db2/V9.7"
  default['db2']['req_packages'] = ["libaio", "dapl", "sg3_utils", "libibcm", "ibsim", "ibutils", "libcxgb3", "libipathverbs", "libibmad", "libibumad", "libipathverbs", "libmthca", "libnes" ]
else 
  #default['db2']['url'] = "http://172.16.0.2/db2_10.1/v10.1fp2_linuxx64_server.tar.gz"
  default['db2']['packages'] = "db2_aese_10.1.2"
  default['db2']['install_dir'] = "/opt/ibm/db2/v10.1"
  default['db2']['req_packages'] = ["libaio", "dapl", "sg3_utils", "libibcm", "ibsim", "ibutils", "libcxgb3", "libipathverbs", "libibmad", "libibumad", "libipathverbs", "libmthca", "libnes", "rdma" ]
end
