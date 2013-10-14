name "cinder-scheduler"
description "Cinder scheduler Service"
run_list(
  "recipe[cinder::scheduler-depends]",
  "recipe[cinder::cinder-setup]",
  "recipe[cinder::cinder-scheduler]"
)
