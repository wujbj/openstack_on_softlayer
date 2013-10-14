name "nova-api"
description "Nova API"
run_list(
  "recipe[nova::api-depends]",
  "recipe[nova::nova-setup]",
  "recipe[nova::api-os-compute]"
)
