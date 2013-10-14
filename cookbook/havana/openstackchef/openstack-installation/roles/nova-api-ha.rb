name "nova-api-ha"
description "create nova-api HA endpoint"
run_list(
  "recipe[openstack-ha::nova-api-depends]",
  "recipe[openstack-ha::nova-api]"
)

override_attributes "keepalived" => { "shared_address" => "true" }
