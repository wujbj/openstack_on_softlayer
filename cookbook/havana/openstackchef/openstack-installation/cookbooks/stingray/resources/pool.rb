
actions :create

def initialize(*args)
  super
  @action = :create
end

attribute :monitors, :kind_of => String, :default => 'Simple HTTP'
attribute :algorithm, :kind_of => String, :default => 'roundrobin'
attribute :nodes, :kind_of => Array, :required => true
