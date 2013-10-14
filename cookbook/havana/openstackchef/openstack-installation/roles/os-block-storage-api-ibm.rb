name "os-block-storage-api-ibm"
description "OpenStack Block Storage API service"
run_list(
  "role[os-block-storage-api]",
  "recipe[openstack-block-storage-ibm::iptables]"
  )

