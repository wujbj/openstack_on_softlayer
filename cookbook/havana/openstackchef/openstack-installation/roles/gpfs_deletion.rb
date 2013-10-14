name "gpfs_deletion"
description "Erase GPFS on specify nodes."
run_list(
  "recipe[gpfs::deletion]"
)
