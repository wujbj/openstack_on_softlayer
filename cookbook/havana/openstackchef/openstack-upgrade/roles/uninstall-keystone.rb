name "uninstall-keystone"
description "Uninstall all keystone components"
run_list(
  "recipe[uninstall::uninstall-keystone]"
)

