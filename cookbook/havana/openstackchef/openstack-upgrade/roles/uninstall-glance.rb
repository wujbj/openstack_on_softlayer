name "uninstall-glance"
description "Uninstall all glance components(glance-api,glance-registry"
run_list(
  "recipe[uninstall::uninstall-glance]"
)

