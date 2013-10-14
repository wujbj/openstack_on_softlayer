name "os-network-api-havana"
description "Quantum server"
run_list(
  "role[os-base]",
  "recipe[openstack-network-havana::server]",
  "recipe[openstack-network-havana::identity_registration]"
  )
