name "os-block-storage-api-cluster"
description "OpenStack Block Storage API service"
run_list(
  "role[os-base]",
  "recipe[openstack-block-storage::api]",
  "recipe[openstack-block-storage::identity_registration]"
  )
