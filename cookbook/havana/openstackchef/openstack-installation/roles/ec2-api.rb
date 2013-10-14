name "ec2-api"
description "Nova API EC2"
run_list(
  "recipe[nova::nova-setup]",
  "recipe[nova::api-ec2]"
)
