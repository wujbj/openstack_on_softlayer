name "os-compute-worker-havana"
description "The compute node, most likely with a hypervisor."
run_list(
  "role[os-base]",
  "recipe[openstack-compute-havana::worker]"
  )

