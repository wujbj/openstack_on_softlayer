name "os-rcfile"
description "Generate OpenStack rcfile"
run_list(
  "recipe[openstack-common::rcfile]"
  )
