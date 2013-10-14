
actions :create

def initialize(*args)
  super
  @action = :create
end

attribute :db_name, :kind_of => String, :required => true
