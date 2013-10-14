name "os-network-dhcp-agent-ibm"
description "Quantum dhcp agent"
run_list(
  "role[os-network-dhcp-agent]",
  "recipe[openstack-network-ibm::iptables_dhcp]"
  )

