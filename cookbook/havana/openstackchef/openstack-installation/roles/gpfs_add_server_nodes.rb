name "gpfs_add_server_nodes"
description "Add server nodes to GPFS cluster."
run_list(
  "recipe[gpfs::add_server_nodes]"
)
