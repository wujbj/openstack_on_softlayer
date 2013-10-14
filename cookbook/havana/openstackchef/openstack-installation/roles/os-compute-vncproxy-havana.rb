name "os-compute-vncproxy-havana"
description "Nova VNC Proxy"
run_list(
  "role[os-base]",
  "recipe[openstack-compute-havana::vncproxy]"
  )

