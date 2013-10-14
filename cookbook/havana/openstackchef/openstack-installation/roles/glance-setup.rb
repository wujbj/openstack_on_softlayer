name "glance-setup"
description "sets up keystone tables and conf files"
run_list(
  "recipe[glance::depends]",
  "recipe[glance::setup]"
)
