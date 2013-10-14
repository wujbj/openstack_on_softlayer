#!/usr/bin/python

from xml.dom import minidom
import pprint
import os
import sys
import subprocess
from optparse import OptionParser

# Returns the text output of a shell command
def shell_eval(shell_cmd) :
  shellarray = [shell_cmd];
  # Stupid Python 2.6 doesn't have check_output method under subprocess module.
  # return subprocess.check_output(shellarray);
  obj = subprocess.Popen(shellarray,  stderr=subprocess.PIPE,  stdout=subprocess.PIPE,
                           close_fds=True, shell=True);
  result = obj.communicate();
  return result[0];

def rmvms(xmlfilename, clustername_to_match):
  #xmldoc = minidom.parse('/etc/scpsetup/nodelist.xml')
  xmldoc = minidom.parse(xmlfilename)
  clusterlist = xmldoc.getElementsByTagName('cluster') 
  
  # Now we go through the nodes again looking for libvirt-managed VMs to create
  phase2_hostnames=""  # for libvirt-managed nodes
  for cluster in clusterlist :
      clustername = cluster.attributes['name'].value
      if clustername != clustername_to_match :
          continue;
      nodelist = cluster.getElementsByTagName('node')
      for node in nodelist :
          hostname = node.getElementsByTagName('hostname')[0].firstChild.nodeValue
          nodetype = node.getElementsByTagName('hwtype')[0].firstChild.nodeValue.lower()
          if nodetype == "kvm" :
              phase2_hostnames += hostname+" ";
              disksize = node.getElementsByTagName('kvm')[0].getAttribute('disksize')
              diskdir = node.getElementsByTagName('kvm')[0].getAttribute('diskdir')
              kvmhost = node.getElementsByTagName('kvm')[0].getAttribute('host')
              os.system("rpower " + hostname + " off")
              os.system("rmvm " + hostname)
              os.system("noderm " + hostname) 


parser = OptionParser()
parser.add_option("-f", "--file", dest="filename",default="/etc/scpsetup/nodelist.xml",
                  help="import cluster definition xml from FILE", metavar="FILE")
parser.add_option("-c", "--cluster", dest="clustername", default="",
                  help="clustername in the xml to process")
(options, args) = parser.parse_args()

# default_xml="/etc/scpsetup/nodelist.xml"
xml_filename = options.filename;
clustername = options.clustername;
#print "Using " + xml_filename + " as the cluster xml definition";
if clustername == "" :
  print "Must specify clustername";
  sys.exit(1);

#xml_filename=str(sys.argv[1])
rmvms(xml_filename,clustername);
