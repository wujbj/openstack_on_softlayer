# Description

Install and configure qpid in stand alone mode and active/passive mode

# Requirements

Chef 11 with Ruby 1.9.x required.

# Platforms

* RHEL-6.x

# Usage

This is a stand alone cookbook, but you can also use this cookbook with `openstack-ops-messaging` cookbooks.

# Resources/Providers

* `qpid_setup` Will setup a QPID single node environment
* `qpid_ha_setup` Will setup a QPID HA environment

# Templates

* `qpidd.conf.erb` For QPID single node environment
* `qpidd-ha.conf.erb` For QPID HA environment

# Recipes

## default

- nothing

## single

- Install and configure QPID in single node mode

## active

- Install and configure QPID HA in active mode

## passive

- Install and configure QPID HA in passive mode

# Attributes

