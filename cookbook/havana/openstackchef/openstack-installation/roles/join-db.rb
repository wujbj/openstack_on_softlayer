name "join-db"
description "Install/Config another part of database in OpenStack"
run_list(
  "recipe[openstack-db::join-db]"
)
