name "ec2-api-ha"
description "creates and HA endpoint for nova-api EC2"
run_list(
  "recipe[openstack-ha::ec2-api-depends]",
  "recipe[openstack-ha::ec2-api]"
)

override_attributes "keepalived" => { "shared_address" => "true" }
