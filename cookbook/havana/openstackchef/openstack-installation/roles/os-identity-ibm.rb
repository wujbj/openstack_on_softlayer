name "os-identity-ibm"
description "Roll-up role for Identity"
run_list(
  "role[os-identity]",
  "recipe[openstack-identity-ibm::iptables]"
  )
