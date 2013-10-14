name "quantum-network-node"
description "Quantum Network Node"
run_list(
  "role[base]",
  "role[quantum-ovs-agent]",
  "role[quantum-dhcp-agent]",
  "role[quantum-l3-agent]"
)

