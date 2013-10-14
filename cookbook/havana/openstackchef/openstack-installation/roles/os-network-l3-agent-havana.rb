name "os-network-l3-agent-havana"
description "Quantum l3 agent"
run_list(
  "role[os-base]",
  "recipe[openstack-network-havana::l3_agent]"
  )
