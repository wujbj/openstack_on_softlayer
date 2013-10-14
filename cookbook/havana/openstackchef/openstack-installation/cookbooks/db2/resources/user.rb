
actions :create

def initialize(*args)
  super
  @action = :create
end

attribute :db_user, :kind_of => String, :required => true
attribute :db_pass, :kind_of => String, :required => true
attribute :db_name, :kind_of => String, :required => true

# attribute :db_schema, :kind_of => String, :required => false
attribute :privileges, :kind_of => String, :default =>'dbadm', :required => false
