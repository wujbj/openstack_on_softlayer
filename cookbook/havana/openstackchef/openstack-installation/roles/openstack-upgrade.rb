name "openstack-upgrade"
description "Upgrade OpenStack RPM packages."
run_list(
  "recipe[openstack-upgrade::openstack-upgrade]"
)
