name "cinder-api-ha"
description "creates ha endpoint for cinder using stignray or haproxy"
run_list(
  "recipe[openstack-ha::cinder-api-depends]",
  "recipe[openstack-ha::cinder-api]"
)

override_attributes "keepalived" => { "shared_address" => "true" }
