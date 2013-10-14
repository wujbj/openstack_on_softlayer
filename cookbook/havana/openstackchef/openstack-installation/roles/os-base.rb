name "os-base"
description "OpenStack Base role"
run_list(
  "recipe[iptables]",
  "recipe[openstack-common]" 
  #"recipe[openstack-common::logging]"
  )
