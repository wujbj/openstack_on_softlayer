require 'socket'

def check_role_num(role, num)
    puts '==========================================='
    puts "Begin Check Role(#{role}), Should be #{num}"
    puts '==========================================='
    query = "(roles:#{role}) AND chef_environment:#{node.chef_environment}"
    result, _, _ = Chef::Search::Query.new.search(:node, query)
    while result.length < num
        sleep(1)
        result, _, _ = Chef::Search::Query.new.search(:node, query)
    end
end

def tcp_connect(ip, port, seconds=2)
    Timeout::timeout(seconds) do
        begin
            TCPSocket.new(ip, port).close
            true
        rescue Errno::ECONNREFUSED, Errno::EHOSTUNREACH
            false
        end
    end
rescue Timeout::Error
    false
end

def check_tcp_connection(ip, port)
    puts '==========================================='
    puts "Begin Check IP(#{ip}):PORT(#{port})"
    puts '==========================================='

    status = tcp_connect(ip, port)
    while status
        sleep(1)
        status = tcp_connect(ip, port)
    end
end

def check_tcp_connection1(ip, port)
    bash "check tcp connection IP:PORT(#{ip}:#{port})" do
        code <<-EOH
        while (! nc -w 1 -zn #{ip} #{port})
        do
            sleep 1
        done
        EOH
    end
end
