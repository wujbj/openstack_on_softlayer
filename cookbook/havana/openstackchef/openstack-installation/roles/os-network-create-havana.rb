name "os-network-create-havana"
description "create neutron network"
run_list(
  "role[os-base]",
  "role[os-rcfile]",
  "recipe[openstack-network-havana::setup]"
  )
