
actions :setup

def initialize(*args)
  super
  @action = :setup
end

attribute :db_name, :kind_of => String, :required => true
attribute :primary_host, :kind_of => String, :required => true
attribute :primary_port, :kind_of => Integer, :required => true
attribute :standby_host, :kind_of => String, :required => true
attribute :standby_port, :kind_of => Integer, :required => true
