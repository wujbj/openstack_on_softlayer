name "os-compute-api-cluster"
description "Roll-up role for all the Compute APIs"
run_list(
  "role[os-compute-api-ec2]",
  "role[os-compute-api-os-compute]",
  "role[os-compute-api-metadata]"
  )
