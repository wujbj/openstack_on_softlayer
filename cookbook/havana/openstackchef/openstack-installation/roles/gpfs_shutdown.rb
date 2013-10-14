name "gpfs_shutdown"
description "Shutdown GPFS on specify nodes."
run_list(
  "recipe[gpfs::shutdown]"
)
