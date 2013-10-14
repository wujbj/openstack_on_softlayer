name "quantum-lb-agent"
description "Quantum LB agent base role"
run_list(
  "role[base]",
  "recipe[quantum::quantum-lb-agent]"
)
