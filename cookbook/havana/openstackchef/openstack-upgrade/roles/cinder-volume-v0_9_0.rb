name "cinder-volume-v0_9_0"
description "Upgrade Ciner volume (with non-HA Controller)"
run_list(
  "recipe[upgrade::upgrade-cinder-volume]"
)
