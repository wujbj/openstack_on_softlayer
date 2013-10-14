name "quantum-ovs"
description "Quantum Server with OpenVswitch Agent"
run_list(
  "role[base]",
   "role[quantum-server]",
   "role[quantum-ovs-agent]",
   "role[quantum-dhcp-agent]",
   "role[quantum-l3-agent]"
)
