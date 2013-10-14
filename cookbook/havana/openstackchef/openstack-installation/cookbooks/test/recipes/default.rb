
value=get_passwords("mysql-root-password")

if not value.nil?
  
#mysql_info = Chef::EncryptedDataBagItem.load("openstack-configs", "mysql")
#password = mysql_info["password"]
  puts "SALMAN" + value
#Chef::Log.info("The mysql password is: '#{value}'")
end
