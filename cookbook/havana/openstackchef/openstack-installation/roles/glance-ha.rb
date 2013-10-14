name "glance-ha"
description "add ha endpoint for glance"
run_list(
  "recipe[openstack-ha::glance-depends]",
  "recipe[openstack-ha::glance]"
)

override_attributes "keepalived" => { "shared_address" => "true" }
