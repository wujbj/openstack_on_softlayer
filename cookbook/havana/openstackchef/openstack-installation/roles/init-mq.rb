name "init-mq"
description "Initialize Message Queue"
run_list(
  "recipe[openstack-mq::init-mq]"
)
