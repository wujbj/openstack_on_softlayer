default['stingray']['url'] = 'http://cwr01/pub/stingray/stingray.tar.gz'
default['stingray']['license_key'] = ''
default['stingray']['password'] = 'passw0rd'
# cluster_host means you first stingray cluster host
# default['stingray']['cluster_host'] = '172.16.1.25'

## stingray flipper(traffic IP group)
default['stingray']['flipper']['name'] = 'test-flipper'
default['stingray']['flipper']['ip'] = '172.16.1.250'
default['stingray']['flipper']['keeptogether'] = 'No'
default['stingray']['flipper']['machines'] = nil

## stingray pool
default['stingray']['pool']['name'] = 'test-pool'
default['stingray']['pool']['monitors'] = 'Simple HTTP'
default['stingray']['pool']['algorithm'] = 'roundrobin'
default['stingray']['pool']['nodes'] = ['172.16.0.1:80', '172.16.1.24:80']

## stingray vserver
default['stingray']['vserver']['name'] = 'test-vserver'
default['stingray']['vserver']['port'] = 8000
default['stingray']['vserver']['pool'] = default['stingray']['pool']['name']
