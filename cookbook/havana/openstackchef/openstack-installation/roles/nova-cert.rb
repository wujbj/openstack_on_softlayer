name "nova-cert"
description "Nova Certificate Service"
run_list(
  "recipe[nova::nova-cert]"
)
