name "yum"
description "Setting up yum repositories"
run_list(
  "recipe[yum::rhel]",
  "recipe[yum::epel]",
  "recipe[yum::openstack]",
  "recipe[yum::addition]"
)
