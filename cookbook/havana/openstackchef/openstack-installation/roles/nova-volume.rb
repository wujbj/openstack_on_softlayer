name "nova-volume"
description "Nova Volume Service"
run_list(
  "recipe[nova::volume]"
)
