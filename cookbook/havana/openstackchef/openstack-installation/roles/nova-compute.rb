name "nova-compute"
description "Nova compute (with non-HA Controller)"
run_list(
  "recipe[nova::nova-setup]",
  "recipe[nova::compute]"
)

