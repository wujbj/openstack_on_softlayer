name "quantum-lb"
description "Quantum Server with LinuxBridge Agent"
run_list(
  "role[base]",
   "role[quantum-server]",
   "role[quantum-lb-agent]",
   "role[quantum-dhcp-agent]",
   "role[quantum-l3-agent]"
)
