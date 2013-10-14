name "cinder-setup"
description "sets up keystone tables and conf files"
run_list(
  "recipe[cinder::api-depends]",
  "recipe[cinder::setup]"
)
