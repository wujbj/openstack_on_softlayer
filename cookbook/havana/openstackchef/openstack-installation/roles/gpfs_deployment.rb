name "gpfs_deployment"
description "To configure and start GPFS cluster."
run_list(
  "recipe[gpfs::deployment]"
)
