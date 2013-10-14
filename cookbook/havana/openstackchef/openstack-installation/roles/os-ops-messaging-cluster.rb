name "os-ops-messaging-cluster"
description "Currently RabbitMQ Server (non-ha)"
run_list(
  "role[os-base]",
  "recipe[openstack-ops-messaging::server-cluster]"
  )
