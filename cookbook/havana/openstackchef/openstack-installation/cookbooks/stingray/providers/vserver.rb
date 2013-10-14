
action :create do
  params = Hash.new()
  attributes = ['pool', 'port']
  attributes.each do |attribute|
    if new_resource.respond_to?(attribute)
      params[attribute] = new_resource.send(attribute.to_sym) unless new_resource.send(attribute.to_sym).nil?
    end
  end

  r = template "/usr/local/zeus/zxtm/conf/vservers/#{new_resource.name}" do
    cookbook "stingray"
    source "vserver.erb"
    owner "root"
    group "root"
    mode "0644"
    variables(
      "name" => new_resource.name,
      "params" => params
    )
  end
  new_resource.updated_by_last_action(r.updated_by_last_action?)
end
