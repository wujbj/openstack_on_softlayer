
action :create do
    if ::File.exists?('/usr/local/zeus/zxtm/conf_A/commkey')
        puts "\n===================================="
        puts "Already initialized stingray cluster"
        puts "===================================="
    else
        params = Hash.new()
        attributes = ['password', 'license_key']
        attributes.each do |attribute|
            if new_resource.respond_to?(attribute)
                params[attribute] = new_resource.send(attribute.to_sym) unless new_resource.send(attribute.to_sym).nil?
            end
        end

        s_dir = '/root/chef_stingray'
        directory "#{s_dir}" do
            owner 'root'
            group 'root'
            mode '0755'
            recursive true
            action :create
        end

        template "#{s_dir}/init_cluster.txt" do
            cookbook "stingray"
            source "init_cluster.erb"
            variables(
                "name" => new_resource.name,
                "params" => params
            )
        end
      
        execute "init cluster" do
            command "/usr/local/zeus/zxtm/configure --replay-from=#{s_dir}/init_cluster.txt"
        end
    end
end
