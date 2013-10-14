name "yum-sce"
description "Setting up yum sce repositories"
run_list(
  "recipe[yum::sce]"
)
