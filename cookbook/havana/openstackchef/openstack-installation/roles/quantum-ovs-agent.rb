name "quantum-ovs-agent"
description "Quantum OVS agent base role"
run_list(
  "recipe[keystone::rcfile]",
  "recipe[quantum::quantum-ovs-agent]"
)
