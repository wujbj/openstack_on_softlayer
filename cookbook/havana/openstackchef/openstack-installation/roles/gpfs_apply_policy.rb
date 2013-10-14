name "gpfs_apply_policy"
description "Apply policy to GPFS cluster."
run_list(
  "recipe[gpfs::apply_policy]"
)
