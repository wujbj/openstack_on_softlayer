name "quantum-dhcp-agent"
description "Quantum dhcp agent"
run_list(
  "recipe[quantum::network]",
  "recipe[quantum::quantum-dhcp-agent]"
)
