
actions :create

def initialize(*args)
  super
  @action = :create
end

attribute :pool, :kind_of => String, :required => true
attribute :port, :kind_of => Integer, :required => true
