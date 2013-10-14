name "keystone-setup"
description "sets up keystone tables and conf files"
run_list(
  "recipe[keystone::depends]",
  "recipe[keystone::setup]"
)
