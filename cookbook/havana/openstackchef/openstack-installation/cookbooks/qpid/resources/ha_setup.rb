
actions :create

def initialize(*args)
  super
  @action = :create
end

attribute :ha_public_url, :kind_of => String, :required => true
attribute :ha_brokers_url, :kind_of => Array, :required => true

attribute :auth, :kind_of => String, :default => 'no', :required => false
attribute :port, :kind_of => Integer, :default => 5672, :required => false

attribute :mech, :kind_of => String, :default => 'QPID', :required => false
attribute :username, :kind_of => String, :default => 'guest', :required => false
attribute :password, :kind_of => String, :default => 'guest', :required => false

attribute :ha_replicate, :kind_of => String, :default => 'all', :required => false
attribute :ha_backup_timeout, :kind_of => Integer, :default => 5, :required => false
attribute :ha_mechanism, :kind_of => String, :default => 'MECH', :required => false
attribute :ha_username, :kind_of => String, :default => 'guest', :required => false
attribute :ha_password, :kind_of => String, :default => 'guest', :required => false
