
actions :install

def initialize(*args)
  super
  @action = :install
end

attribute :url, :kind_of => String, :required => true
