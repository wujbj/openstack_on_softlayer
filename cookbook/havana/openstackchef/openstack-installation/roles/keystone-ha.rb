name "keystone-ha"
description "add keystone ha endpoint"
run_list(
  "recipe[openstack-ha::keystone-depends]",
  "recipe[openstack-ha::keystone]"
)

override_attributes "keepalived" => { "shared_address" => "true" }
