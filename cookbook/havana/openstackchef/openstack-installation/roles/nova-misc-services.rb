name "nova-misc-services"
description "Nova Controller (non-HA)"
run_list(
  "recipe[nova::nova-common]",
  "recipe[nova::vncproxy]",
  "recipe[nova::volume]",
  "recipe[horizon::server]"
)

