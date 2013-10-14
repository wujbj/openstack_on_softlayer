name "os-compute-cert-havana"
description "OpenStack Compute Cert service"
run_list(
  "role[os-base]",
  "recipe[openstack-compute-havana::cert]"
  )
