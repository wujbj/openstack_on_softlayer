name "os-ops-database-cluster"
description "database"
run_list(
  "role[os-base]",
  "recipe[openstack-ops-database::server-cluster]"
)
