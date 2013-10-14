name "nova-compute-ovs"
description "Nova compute with OVS agent (with non-HA Controller)"
run_list(
  "role[quantum-ovs-agent]",
  "recipe[nova::nova-setup]",
  "recipe[nova::compute]"
)

