name "os-network-dhcp-agent-havana"
description "Quantum dhcp agent"
run_list(
  "role[os-base]",
  "recipe[openstack-network-havana::dhcp_agent]"
  )
