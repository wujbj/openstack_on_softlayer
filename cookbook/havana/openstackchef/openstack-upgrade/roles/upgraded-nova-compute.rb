name "upgraded-nova-compute"
description "Upgrade Nova compute (with non-HA Controller)"
run_list(
  "recipe[upgrade::upgrade-nova-compute-epel]"
)

