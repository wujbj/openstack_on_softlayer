name "gpfs_upgrade"
description "Upgrade GPFS on specify nodes."
run_list(
  "recipe[gpfs::upgrade]"
)
