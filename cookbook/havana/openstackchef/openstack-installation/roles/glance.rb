name "glance"
description "Glance server"
run_list(
  "recipe[glance::depends]",
  "recipe[glance::registry]",
  "recipe[glance::api]"
)
