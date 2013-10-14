name "init-cluster"
description "initialize a cluster"
run_list(
  "recipe[openstack-ha::init-cluster]"
)
