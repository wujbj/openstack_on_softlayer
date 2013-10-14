name "quantum-l3-agent"
description "Quantum L3 agent"
run_list(
  "role[base]",
  "recipe[quantum::quantum-l3-agent]"
)

