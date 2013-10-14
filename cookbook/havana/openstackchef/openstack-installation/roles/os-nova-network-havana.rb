name "os-nova-network-havana"
description "Nova network havana (with non-HA Controller)"
run_list(
  "role[os-base]",
  "recipe[openstack-compute-havana::network]"
)

