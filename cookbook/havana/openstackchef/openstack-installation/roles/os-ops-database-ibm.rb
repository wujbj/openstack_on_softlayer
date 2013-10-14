name "os-ops-database-ibm"
description "IBM specific database configuration for primary node"
run_list(
  "role[os-base]",
  "recipe[openstack-ops-database-ibm::default]"
)
