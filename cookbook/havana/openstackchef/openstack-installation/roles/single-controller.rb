name "single-controller"
description "Single Controller"
run_list(
  "role[init-db]",
  "role[keystone]",
  "role[init-mq]",
  "role[glance]",
  "role[cinder-api]",
  "role[cinder-scheduler]",
  "role[nova-api]",
  "role[ec2-api]",
  "role[nova-scheduler]",
  "role[nova-conductor]"
)
