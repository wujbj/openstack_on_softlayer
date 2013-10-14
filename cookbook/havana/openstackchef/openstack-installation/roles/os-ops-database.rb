name "os-ops-database"
description "database"
run_list(
  "role[os-base]",
  "recipe[openstack-ops-database::server]",
  "recipe[openstack-ops-database::openstack-db]"
)
