<!-- title: Demo OpenStack Upgrade -->
<!-- subtitle: Demo OpenStack Upgrade -->

Description
===========

Demo Openstack packages upgrade

Requirements
============

Chef 0.10.0 or higher required (for Chef environment use).

Platforms
--------

* RHEL6.3

Cookbooks
---------

The following cookbooks are dependencies:

* nova-upgrade
* cinder-upgrade

Resources/Providers
===================

None


Recipes
=======

nova-upgrade
----
-Includes recipe `nova-common`
-Installs AWS EC2 compatible API and configures the service and endpoints in keystone

cinder-upgrade
---
- Includes recipe `monit::server`
- Configures monit process monitoring for the nova-api-ec2 service
- Included from recipe `nova::api-ec2`

Attributes
==========

Templates
=====

License and Author
==================

Author:: Tao Tao (<ttao@us.ibm.com>)

Copyright 2013, IBM, Inc.

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
