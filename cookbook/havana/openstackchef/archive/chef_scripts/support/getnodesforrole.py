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

def role_nodes(xmlfilename,clustername_to_match,reqd_role):
  #xmldoc = minidom.parse('/etc/scpsetup/nodelist.xml')
  xmldoc = minidom.parse(xmlfilename)
  clusterlist = xmldoc.getElementsByTagName('cluster') 
  for cluster in clusterlist :
    clustername = cluster.attributes['name'].value
    if clustername != clustername_to_match :
      continue;
    nodelist = cluster.getElementsByTagName('node')
    for node in nodelist :
      hostname = node.getElementsByTagName('hostname')[0].firstChild.nodeValue;
      role = node.getElementsByTagName('role')[0].firstChild.nodeValue;
      if (role.find(reqd_role)>=0) :
        osmgmtlist = node.getElementsByTagName('osmgmt');
        if ( osmgmtlist != None and len(osmgmtlist) > 0 ) :
          osmgmt_ip = osmgmtlist[0].getAttribute('ip');
          print osmgmt_ip;

parser = OptionParser()
parser.add_option("-f", "--file", dest="filename",default="/etc/scpsetup/nodelist.xml",
                  help="import cluster definition xml from FILE", metavar="FILE")
parser.add_option("-c", "--cluster", dest="clustername", default="",
                  help="clustername in the xml to process")
parser.add_option("-r", "--role", dest="role", default="",
                  help="-r or --role to process")
(options, args) = parser.parse_args()

xml_filename = options.filename;
clustername = options.clustername;
role = options.role;
if clustername == "" :
  print "Must specify clustername";
  sys.exit(1);
#if role == "" :
#  print "Must specify role";
#  sys.exit(1);

#xml_filename=str(sys.argv[1])
#role=str(sys.argv[2])
role_nodes(xml_filename,clustername,role)
