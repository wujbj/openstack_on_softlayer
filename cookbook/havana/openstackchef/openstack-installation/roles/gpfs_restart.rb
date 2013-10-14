name "gpfs_restart"
description "Restart GPFS on specify nodes."
run_list(
  "recipe[gpfs::restart]"
)
