
action :install do
    if ::File.exists?('/usr/local/zeus')
        puts "\n=========================="
        puts "Stingray already installed"
        puts "=========================="
    else
        s_dir = '/root/chef_stingray'
        directory "#{s_dir}" do
            owner "root"
            group "root"
            mode "0755"
            recursive true
            action :create
        end

        s_pkgname = new_resource.url.split('/').last.to_s
        execute "Download stingray package" do
            cwd s_dir
            command "wget -O #{s_pkgname} #{new_resource.url}"
        end

        install_file = "#{s_dir}/install_stingray.txt"
        template "#{install_file}" do
            cookbook "stingray"
            source "install_stingray.erb"
        end

        execute "Install stingray" do
            cwd s_dir
            command "tar xf #{s_pkgname} && ./stingray/zinstall --replay-from=#{install_file}"
        end
    end
end
