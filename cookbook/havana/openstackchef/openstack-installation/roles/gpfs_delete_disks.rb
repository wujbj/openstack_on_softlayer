name "gpfs_delete_disks"
description "Delete disks from GPFS filesystem."
run_list(
  "recipe[gpfs::delete_disks]"
)
