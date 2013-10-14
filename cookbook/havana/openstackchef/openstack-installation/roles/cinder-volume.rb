name "cinder-volume"
description "Cinder Volume Service"
run_list(
  "recipe[cinder::volume-depends]",
  "recipe[cinder::cinder-volume]"
)
