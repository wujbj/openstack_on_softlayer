
actions :install

def initialize(*args)
  super
  @action = :install
end

#attribute :odbc_url, :kind_of => String, :required => true
attribute :odbc_packages, :kind_of => String, :required => true

# Optional attributes
attribute :odbc_install_dir, :kind_of => String, :default => "/opt/ibm", :required => false
attribute :odbc_req_packages, :kind_of => Array, :default => ["python-sqlalchemy", "python-migrate", "python-ibm-db", "python-ibm-db-sa"], :required => false
