
action :create do
  params = Hash.new()
  attributes = ['auth', 'port']
  attributes.each do |attribute|
    if new_resource.respond_to?(attribute)
      params[attribute] = new_resource.send(attribute.to_sym) unless new_resource.send(attribute.to_sym).nil?
    end
  end

  pkgs = node['qpid']['packages']

  # Install qpid packages
  pkgs.each do |pkg|
    package "#{pkg}" do
      action :install
      retries 5
      retry_delay 10
    end
  end

  # Define qpid service resource
  service "qpidd" do
    action :nothing
  end

  # Create qpidd.conf file
  r = template "/etc/qpidd.conf" do
    cookbook "qpid"
    source "qpidd.conf.erb"
    owner "root"
    group "root"
    mode "0644"
    variables(
      "name" => new_resource.name,
      "params" => params
    )
    notifies :restart, resources(:service => "qpidd"), :immediately
  end
  new_resource.updated_by_last_action(r.updated_by_last_action?)

end
