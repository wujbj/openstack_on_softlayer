name "os-network-api-ibm"
description "Quantum server"
run_list(
  "role[os-network-api]",
  "recipe[openstack-network-ibm::iptables_server]"
  )

