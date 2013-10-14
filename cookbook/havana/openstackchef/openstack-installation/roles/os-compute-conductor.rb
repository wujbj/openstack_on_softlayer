name "os-compute-conductor"
description "OpenStack Compute Conductor service"
run_list(
  "role[os-base]",
  "recipe[openstack-compute::conductor]"
  )
