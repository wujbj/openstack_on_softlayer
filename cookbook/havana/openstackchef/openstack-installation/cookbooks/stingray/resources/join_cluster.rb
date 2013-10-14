
actions :create

def initialize(*args)
  super
  @action = :create
end

attribute :password, :kind_of => String, :required => true
attribute :cluster_host, :kind_of => String, :required => true
