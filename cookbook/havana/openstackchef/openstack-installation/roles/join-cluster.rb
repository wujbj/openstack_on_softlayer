name "join-cluster"
description "join a cluster"
run_list(
  "recipe[openstack-ha::join-cluster]"
)
