
actions :install, :restart

def initialize(*args)
  super
  @action = :install
end

#attribute :url, :kind_of => String, :required => true
attribute :packages, :kind_of => String, :required => true
attribute :das_password, :kind_of => String, :required => true
attribute :instance_password, :kind_of => String, :required => true
attribute :fenced_password, :kind_of => String, :required => true

# Optional attributes
attribute :port, :kind_of => Integer, :default => 50000, :required => false
attribute :fcm_port, :kind_of => Integer, :default => 60000, :required => false
attribute :max_logical_nodes, :kind_of => Integer, :default => 4, :required => false
attribute :install_dir, :kind_of => String, :default => "/opt/ibm/db2/v10.1", :required => false
attribute :instance_type, :kind_of => String, :equal_to => ["DSF", "ESE", "WSE", "STANDALONE", "CLIENT"], :default => "ESE", :required => false
attribute :instance_username, :kind_of => String, :default => "db2inst1", :required => false
attribute :instance_home_dir, :kind_of => String, :default => "/home/db2inst1", :required => false
attribute :fenced_username, :kind_of => String, :default => "db2fenc1", :required => false
attribute :das_username, :kind_of => String, :default => "db2das1", :required => false
attribute :req_packages, :kind_of => Array, :default => ["libaio", "dapl", "sg3_utils", "libibcm", "ibsim", "ibutils", "libcxgb3", "libipathverbs", "libibmad", "libibumad", "libipathverbs", "libmthca", "libnes", "rdma"], :required => false
