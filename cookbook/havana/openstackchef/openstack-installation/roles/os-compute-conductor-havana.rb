name "os-compute-conductor-havana"
description "OpenStack Compute Conductor service"
run_list(
  "role[os-base]",
  "recipe[openstack-compute-havana::conductor]"
  )
