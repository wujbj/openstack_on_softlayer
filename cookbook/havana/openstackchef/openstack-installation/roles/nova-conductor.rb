name "nova-conductor"
description "Nova conductor"
run_list(
  "recipe[nova::conductor-depends]",
  "recipe[nova::nova-setup]",
  "recipe[nova::conductor]"
)
