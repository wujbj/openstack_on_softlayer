name "gpfs_add_nodes"
description "Add nodes to GPFS cluster."
run_list(
  "recipe[gpfs::add_nodes]"
)
