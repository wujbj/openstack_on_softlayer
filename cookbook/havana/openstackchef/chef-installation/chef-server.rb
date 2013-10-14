# chef-server configuration file: /etc/chef-server/chef-server.rb
server_name = '9.115.78.197'
api_fqdn server_name

nginx['url'] = "https://#{server_name}"
nginx['server_name'] = server_name
#lb['fqdn'] = server_name
bookshelf['vip'] = server_name

## http://lists.opscode.com/sympa/arc/chef/2013-02/msg00475.html
chef_solr['commit_interval'] = 1000 # in ms
