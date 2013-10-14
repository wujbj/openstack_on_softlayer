name "nova-compute-lb"
description "Nova compute with LB agent (with non-HA Controller)"
run_list(
  "role[quantum-lb-agent]",
  "recipe[nova::nova-setup]",
  "recipe[nova::compute]"
)

