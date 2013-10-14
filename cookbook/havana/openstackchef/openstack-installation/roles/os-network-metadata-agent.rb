name "os-network-metadata-agent"
description "Quantum metadata agent"
run_list(
  "role[os-base]",
  "recipe[openstack-network::metadata_agent]"
  )
