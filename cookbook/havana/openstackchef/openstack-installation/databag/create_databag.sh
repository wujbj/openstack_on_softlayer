################################
# create databag
###############################

base_dir=$(cd $(dirname $0) && pwd)

bags=(db_passwords user_passwords service_passwords secrets)
key_path=$base_dir/databag-key

## Generate databag key
openssl rand -base64 512 > $key_path
/bin/cp -f $key_path /etc/chef-server/

## Add to knife.rb file
if ! grep -w -q 'encrypted_data_bag_secret' /root/.chef/knife.rb; then
  echo "encrypted_data_bag_secret '/etc/chef-server/databag-key'" >> /root/.chef/knife.rb
fi

## Delete old databags
knife data bag list | xargs -i knife data bag delete -y {}

## Create databags and upload items
for bag in ${bags[@]}
do
  knife data bag create --secret-file $key_path $bag
  items=$(ls $base_dir/$bag)
  for item in $items
  do
    knife data bag from file $bag $base_dir/$bag/$item --secret-file $key_path 
  done
done
