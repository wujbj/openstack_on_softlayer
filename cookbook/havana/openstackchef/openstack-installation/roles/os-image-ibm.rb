name "os-image-ibm"
description "Roll-up role for Glance."
run_list(
  "role[os-image]",
  "recipe[openstack-image-ibm::iptables-api]",
  "recipe[openstack-image-ibm::iptables-registry]"
)
