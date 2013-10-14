# qpid broker option
default['qpid']['broker']['port'] = 5672
default['qpid']['broker']['auth'] = 'no'

# qpid log option
#default['qpid']['log']['log_level'] = nil

# qpid ha option
default['qpid']['ha']['vip'] = '172.16.1.20'
default['qpid']['ha']['vip_if'] = 'eth0'
default['qpid']['ha']['brokers_url'] = ['172.16.1.25', '172.16.1.26']

default['qpid']['ha']['replicate'] = 'all'
default['qpid']['ha']['backup_timeout'] = 5
default['qpid']['ha']['username'] = 'guest'
default['qpid']['ha']['password'] = 'guest'
default['qpid']['ha']['mechanism'] = 'MECH'

case platform
when "fedora", "redhat", "centos"
  default['qpid']['packages'] = ['qpid-cpp-server', 'qpid-tools']
  default['qpid']['ha_packages'] = ['qpid-cpp-server-ha', 'python-qpid-qmf']
when "ubuntu", "debian"
  exit("This cookbook doesn't support your platform(#{platform})")
end
