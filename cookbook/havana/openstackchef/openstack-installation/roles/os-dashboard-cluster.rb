name "os-dashboard-cluster"
description "Horizon server"
run_list(
    "role[os-base]",
    "recipe[openstack-dashboard::server]"
)
