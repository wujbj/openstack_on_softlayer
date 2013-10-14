name "keystone"
description "Keystone server"
run_list(
  "recipe[keystone::depends]",
  "recipe[keystone::server]"
)

