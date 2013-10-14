name "os-compute-api-os-compute-havana"
description "OpenStack API for Compute"
run_list(
  "role[os-base]",
  "recipe[openstack-compute-havana::api-os-compute]"
  )
