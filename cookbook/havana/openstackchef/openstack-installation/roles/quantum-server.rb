name "quantum-server"
description "quantum server"
run_list(
  "recipe[quantum::server-depends]",
  "recipe[quantum::quantum-server]"
)
