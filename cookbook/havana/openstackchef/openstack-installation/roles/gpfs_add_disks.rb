name "gpfs_add_disks"
description "Add disks to GPFS filesystem."
run_list(
  "recipe[gpfs::add_disks]"
)
