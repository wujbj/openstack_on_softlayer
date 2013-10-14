name "gpfs_termination"
description "Stop GPFS on specify nodes."
run_list(
  "recipe[gpfs::termination]"
)
