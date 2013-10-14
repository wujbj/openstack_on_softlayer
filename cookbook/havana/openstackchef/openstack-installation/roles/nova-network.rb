name "nova-network"
description "Nova network (with non-HA Controller)"
run_list(
  "recipe[nova::network]"
)

