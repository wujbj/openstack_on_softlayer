name "os-nova-network"
description "Nova network (with non-HA Controller)"
run_list(
  "role[os-base]",
  "recipe[openstack-compute::network]"
)

