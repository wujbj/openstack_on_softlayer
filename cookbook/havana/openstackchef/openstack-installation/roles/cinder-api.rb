name "cinder-api"
description "Cinder API Service"
run_list(
  "recipe[cinder::api-depends]",
  "recipe[cinder::cinder-setup]",
  "recipe[cinder::cinder-api]"
)
