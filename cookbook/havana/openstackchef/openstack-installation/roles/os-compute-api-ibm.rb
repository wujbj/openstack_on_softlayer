name "os-compute-api-ibm"
description "Roll-up role for all the Compute APIs"
run_list(
  "role[os-compute-api-ec2]",
  "role[os-compute-api-os-compute]",
  "role[os-compute-api-metadata]",
  "recipe[openstack-compute-ibm::iptables-api]",
  "recipe[openstack-compute-ibm::iptables-ec2api]",
  "recipe[openstack-compute-ibm::iptables-metadata]"
  )
