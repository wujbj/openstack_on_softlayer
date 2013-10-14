name "os-ops-database-cluster-ibm"
description "IBM specific database cluster configuration"
run_list(
  "role[os-base]",
  "recipe[openstack-ops-database-ibm::cluster]"
  )
