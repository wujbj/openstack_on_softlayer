
actions :create

def initialize(*args)
  super
  @action = :create
end

attribute :ipaddress, :kind_of => String, :required => true
attribute :keeptogether, :kind_of => String, :default => "No", :required => false
attribute :machines, :kind_of => String, :default => nil, :required => false
