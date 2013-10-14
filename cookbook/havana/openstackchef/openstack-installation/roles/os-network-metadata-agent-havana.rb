name "os-network-metadata-agent-havana"
description "Quantum metadata agent"
run_list(
  "role[os-base]",
  "recipe[openstack-network-havana::metadata_agent]"
  )
