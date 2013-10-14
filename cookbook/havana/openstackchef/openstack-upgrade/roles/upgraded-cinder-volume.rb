name "upgraded-cinder-volume"
description "Upgrade Ciner volume (with non-HA Controller)"
run_list(
  "recipe[upgrade::upgrade-cinder-volume-epel]"
)

