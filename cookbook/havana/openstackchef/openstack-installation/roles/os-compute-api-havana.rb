name "os-compute-api-havana"
description "Roll-up role for all the Compute APIs"
run_list(
  "role[os-compute-api-ec2-havana]",
  "role[os-compute-api-os-compute-havana]",
  "role[os-compute-api-metadata-havana]"
  )
