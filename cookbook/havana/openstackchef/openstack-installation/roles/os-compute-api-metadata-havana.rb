name "os-compute-api-metadata-havana"
description "OpenStack compute metadata API service"
run_list(
  "role[os-base]",
  "recipe[openstack-compute-havana::api-metadata]"
  )
