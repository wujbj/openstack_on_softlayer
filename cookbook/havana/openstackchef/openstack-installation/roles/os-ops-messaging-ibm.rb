name "os-ops-messaging-ibm"
description "IBM specific messaging configuration"
run_list(
  "role[os-base]",
  "recipe[openstack-ops-messaging-ibm]"
  )
