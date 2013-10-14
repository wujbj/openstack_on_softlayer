name "gpfs_delete_nodes"
description "Delete nodes from GPFS cluster."
run_list(
  "recipe[gpfs::delete_nodes]"
)
