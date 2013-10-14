name "join-mq"
description "Join an exist Message Queue"
run_list(
  "recipe[openstack-mq::join-mq]"
)
