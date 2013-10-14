name "os-ha-endpoints-cluster"
description "Roll-up role for endpoints"
run_list(
  "role[os-base]",
  "recipe[openstack-cluster::endpoints-cluster]"
  )
