name "nova-vncproxy"
description "Nova VNC Proxy"
run_list(
  "recipe[nova::vncproxy]"
)

