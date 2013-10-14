
actions :create

def initialize(*args)
  super
  @action = :create
end

attribute :password, :kind_of => String, :required => true
attribute :license_key, :kind_of => String, :required => true
