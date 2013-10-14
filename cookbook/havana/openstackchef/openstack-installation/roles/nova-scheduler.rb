name "nova-scheduler"
description "Nova scheduler"
run_list(
  "recipe[nova::scheduler-depends]",
  "recipe[nova::scheduler]"
)
