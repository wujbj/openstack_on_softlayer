name "nova-compute-v1_0_0"
description "Upgrade Nova compute (with non-HA Controller)"
run_list(
  "recipe[upgrade::upgrade-nova-compute]"
)

