name "os-compute-api-ec2-havana"
description "EC2 API for Compute"
run_list(
  "role[os-base]",
  "recipe[openstack-compute-havana::api-ec2]",
  "recipe[openstack-compute-havana::nova-setup]",
  "recipe[openstack-compute-havana::identity_registration]"
  )
