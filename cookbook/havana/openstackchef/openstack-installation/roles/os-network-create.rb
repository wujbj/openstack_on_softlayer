name "os-network-create"
description "create quantum network"
run_list(
  "role[os-base]",
  "role[os-rcfile]",
  "recipe[openstack-network::setup]"
  )
