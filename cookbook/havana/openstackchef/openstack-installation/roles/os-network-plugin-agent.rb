name "os-network-plugin-agent"
description "Quantum plugin agent"
run_list(
  "role[os-base]",
  "recipe[openstack-network::openvswitch]"
  )
