name "os-network-l3-agent"
description "Quantum l3 agent"
run_list(
  "role[os-base]",
  "recipe[openstack-network::l3_agent]"
  )
