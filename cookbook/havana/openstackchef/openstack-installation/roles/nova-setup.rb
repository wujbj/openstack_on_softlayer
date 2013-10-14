name "nova-setup"
description "sets up keystone tables and conf files"
run_list(
  "recipe[nova::api-depends]",
  "recipe[nova::setup]"
)
