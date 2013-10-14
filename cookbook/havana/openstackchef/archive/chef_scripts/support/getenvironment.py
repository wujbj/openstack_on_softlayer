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

def getenvironment(xmlfilename,clustername_to_match):
  #xmldoc = minidom.parse('/etc/scpsetup/nodelist.xml')
  xmldoc = minidom.parse(xmlfilename)
  clusterlist = xmldoc.getElementsByTagName('cluster') 
  for cluster in clusterlist :
    clustername = cluster.attributes['name'].value
    if clustername != clustername_to_match :
      continue;
    environment = cluster.getElementsByTagName('environment')[0]
    if hasattr(environment.attributes,'chefserver') :
      chefserver = environment.attributes['chefserver'].value;
    else :
      chefserver="10.145.1.15";
    chefserver = environment.attributes['chefserver'].value
    environmentname = environment.attributes['name'].value
    bridge=environment.getElementsByTagName('bridge')[0].firstChild.nodeValue
    bridgedev=environment.getElementsByTagName('bridgedev')[0].firstChild.nodeValue
    pubnet=environment.getElementsByTagName('pubnet')[0].firstChild.nodeValue
    novanet=environment.getElementsByTagName('novanet')[0].firstChild.nodeValue
    mgmtnet=environment.getElementsByTagName('mgmtnet')[0].firstChild.nodeValue
    vmnet=environment.getElementsByTagName('vmnet')[0].firstChild.nodeValue
    vmnetnum=environment.getElementsByTagName('vmnetnum')[0].firstChild.nodeValue
    vmnetsize=environment.getElementsByTagName('vmnetsize')[0].firstChild.nodeValue
    floating=environment.getElementsByTagName('floating')[0].firstChild.nodeValue
    print chefserver+" "+environmentname+" "+bridge+" "+bridgedev+" "+pubnet+" "+novanet+" "+mgmtnet+" "+vmnet+" "+vmnetnum+" "+vmnetsize+" "+floating;

parser = OptionParser()
parser.add_option("-f", "--file", dest="filename",default="/etc/scpsetup/nodelist.xml",
                  help="import cluster definition xml from FILE", metavar="FILE")
parser.add_option("-c", "--cluster", dest="clustername", default="",
                  help="clustername in the xml to process")
(options, args) = parser.parse_args()

xml_filename = options.filename;
clustername = options.clustername;
if clustername == "" :
  print "Must specify clustername";
  sys.exit(1);

getenvironment(xml_filename,clustername)
