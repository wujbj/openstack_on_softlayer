name "quantum-server-ha"
description "create quantum ha endpoint"
run_list(
  "recipe[openstack-ha::quantum-server-depends]",
  "recipe[openstack-ha::quantum-server]"
)

override_attributes "keepalived" => { "shared_address" => "true" }
