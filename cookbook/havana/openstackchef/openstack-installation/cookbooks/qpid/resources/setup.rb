
actions :create

def initialize(*args)
  super
  @action = :create
end

attribute :auth, :kind_of => String, :default => 'no', :required => false
attribute :port, :kind_of => Integer, :default => 5672, :required => false

attribute :mech, :kind_of => String, :default => 'QPID', :required => false
attribute :username, :kind_of => String, :default => 'guest', :required => false
attribute :password, :kind_of => String, :default => 'guest', :required => false
