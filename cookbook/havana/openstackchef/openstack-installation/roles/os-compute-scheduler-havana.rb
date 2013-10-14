name "os-compute-scheduler-havana"
description "Nova scheduler"
run_list(
  "role[os-base]",
  "recipe[openstack-compute-havana::scheduler]"
  )
