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

def installbaseos(xmlfilename, clustername_to_match, nodenames_filter):
  #xmldoc = minidom.parse('/etc/scpsetup/nodelist.xml')
  xmldoc = minidom.parse(xmlfilename)
  clusterlist = xmldoc.getElementsByTagName('cluster') 
  
  # The first pass is for physical nodes only
  phase1_hostnames="" 
  for cluster in clusterlist :
      clustername = cluster.attributes['name'].value
      if clustername != clustername_to_match :
          continue;
      nodelist = cluster.getElementsByTagName('node')
      for node in nodelist :
          hostname = node.getElementsByTagName('hostname')[0].firstChild.nodeValue;
          nodetype = node.getElementsByTagName('hwtype')[0].firstChild.nodeValue.lower();
          if nodenames_filter != None and hostname not in nodenames_filter :
              continue
          if nodetype == "blade" :
              os.system( "rbootseq " + hostname + " n");
              phase1_hostnames += hostname+" ";
          elif nodetype == "imm-managed" or nodetype == "idataplex" :
              os.system( "rsetboot " + hostname + " net");
              phase1_hostnames += hostname+" ";

  if phase1_hostnames != "" :
      os.system( "rinstall " + phase1_hostnames);
      print("Will wait for physical hosts " + phase1_hostnames + " to be booted");
      os.system(sys.path[0]+"/deps/waitForBaseOSInstall.sh "+ phase1_hostnames);

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
          if nodenames_filter != None and hostname not in nodenames_filter :
              continue
          if nodetype == "kvm" :
              phase2_hostnames += hostname+" ";
              disksize = node.getElementsByTagName('kvm')[0].getAttribute('disksize')
              diskdir = node.getElementsByTagName('kvm')[0].getAttribute('diskdir')
              kvmhost = node.getElementsByTagName('kvm')[0].getAttribute('host')      
              os.system("psh " + kvmhost + " \"mkdir -p " + diskdir + "\" ")
              os.system("psh " + kvmhost + " \"chmod o+x " + diskdir + "\" ") # So the qemu userid can use this dir
              os.system("mkvm " + hostname + " -s " + disksize)
              os.system("rinstall " + hostname)

  if phase2_hostnames != "" :
      print("Will wait for virtual nodes " + phase2_hostnames + " to be booted");
      os.system(sys.path[0]+"/deps/waitForBaseOSInstall.sh "+ phase2_hostnames);
            

parser = OptionParser()
parser.add_option("-f", "--file", dest="filename",default="/etc/scpsetup/nodelist.xml",
                  help="import cluster definition xml from FILE", metavar="FILE")
parser.add_option("-c", "--cluster", dest="clustername", default="",
                  help="clustername in the xml to process")
parser.add_option("-n", "--nodes", dest="nodenames", default="",
                  help="comma-separated list of subset of nodes in a cluster to do the install on")
(options, args) = parser.parse_args()

xml_filename = options.filename
clustername = options.clustername
nodenames_filter = options.nodenames.split(',')
if len(nodenames_filter) == 0 or nodenames_filter[0] == '':
    nodenames_filter = None
# print "nodenames_filter is " + pprint.pformat(nodenames_filter)

#print "Using " + xml_filename + " as the cluster xml definition";
if clustername == "" :
    print "Must specify clustername";
    sys.exit(1);

#xml_filename=str(sys.argv[1])
installbaseos(xml_filename,clustername,nodenames_filter);
