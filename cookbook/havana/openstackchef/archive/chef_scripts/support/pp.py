#!/usr/bin/python
import os, sys
import yum

yb = yum.YumBase()
yb.conf.cache = os.geteuid() != 1
pl = yb.doPackageLists(patterns=sys.argv[1:])
print pl
if pl.installed:
    print "Installed Packages"
    for pkg in sorted(pl.installed):
        print pkg
if pl.available:
    print "Available Packages"
    for pkg in sorted(pl.available):
        print pkg, pkg.repo
if pl.reinstall_available:
    print "Re-install Available Packages"
    for pkg in sorted(pl.reinstall_available):
        print pkg, pkg.repo
