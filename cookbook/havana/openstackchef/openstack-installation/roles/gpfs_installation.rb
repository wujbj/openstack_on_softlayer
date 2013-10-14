name "gpfs_installation"
description "Install GPFS on specify nodes."
run_list(
  "recipe[gpfs::gpfs]",
  "recipe[gpfs::installation]"
)
