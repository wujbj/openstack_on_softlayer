name "nova-compute-v0_9_0"
description "Upgrade Nova compute (with non-HA Controller)"
run_list(
  "recipe[upgrade::upgrade-nova-compute]"
)

