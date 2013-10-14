name "init-db"
description "Install/Create database of OpenStack"
run_list(
  "recipe[openstack-db::init-db]"
)
