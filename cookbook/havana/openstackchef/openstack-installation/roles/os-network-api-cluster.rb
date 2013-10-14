name "os-network-api-cluster"
description "Quantum server"
run_list(
  "role[os-base]",
  "recipe[openstack-network::server]",
  "recipe[openstack-network::identity_registration]"
  )
