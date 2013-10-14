name "os-compute-api-ec2"
description "EC2 API for Compute"
run_list(
  "role[os-base]",
  "recipe[openstack-compute::api-ec2]",
  "recipe[openstack-compute::nova-setup]",
  "recipe[openstack-compute::identity_registration]"
  )
