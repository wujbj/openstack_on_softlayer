require 'fileutils'

module RCB
  def update_hosts(ip, hostname)
    hostsfile = Array.new
    found = 0
    new_host = "#{ip}	#{hostname}"
    File.open("/etc/hosts", "r") do |infile|
      while (line = infile.gets)
        if /\s#{hostname}\s/.match(line)
          # update the ip and hostname
          Chef::Log.info("hosts: updating #{new_host}")
          hostsfile << new_host
          found = 1
        else
          hostsfile << "#{line}"
        end
      end
    end
    if (found == 0)
      # append the ip and hostname
      Chef::Log.info("hosts: append #{new_host}")
      hostsfile << new_host
    end

    f = Tempfile.new('hosts','/tmp')
    tmppath = f.path
    Chef::Log.info("hosts: writing #{tmppath}")
    hostsfile.each do |line|
      if line.end_with?("\n")
        f.write(line)
      else
        f.write("#{line}\n")
      end
    end
    f.close
    Chef::Log.info("hosts: moving #{tmppath} to /etc/hosts")
    FileUtils.chmod(0644,tmppath);
    FileUtils.mv(tmppath,'/etc/hosts', :force => true)
  end

end
