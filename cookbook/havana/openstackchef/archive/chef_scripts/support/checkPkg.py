#!/usr/bin/python
import os, sys
import yum
import socket

yb = yum.YumBase()
yb.conf.cache = os.geteuid() != 1
#pl = yb.doPackageLists(patterns=sys.argv[1:])
pl = yb.doPackageLists("*openstack*")
hostname = socket.gethostname()

if pl.installed:
    print "The following openstack Packages is already Installed on: ",hostname
    for pkg in sorted(pl.installed):
        print pkg
    sys.exit(102);
else:
   print "No Openstack component is installed,start to append it on: ", hostname
   sys.exit(101)
