name "os-network-plugin-agent-havana"
description "Quantum plugin agent"
run_list(
  "role[os-base]",
  "recipe[openstack-network-havana::openvswitch]"
  )
