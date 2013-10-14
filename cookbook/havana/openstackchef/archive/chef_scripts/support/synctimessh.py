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

def getClusterElement(xmldoc, clustername_to_match) :
  clusterlist = xmldoc.getElementsByTagName('cluster')
  for cluster in clusterlist :
    clustername = cluster.attributes['name'].value
    if clustername != clustername_to_match :
      continue;
    return cluster;
  return None;

def getNodeNames(clusterelement) :
  nodenamearray = []
  nodelist = clusterelement.getElementsByTagName('node')
  for node in nodelist :
      hostname = node.getElementsByTagName('hostname')[0].firstChild.nodeValue;
      nodenamearray.append(hostname);
  return nodenamearray;



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
print xml_filename  
xmldoc = minidom.parse(xml_filename)
clusterElement = getClusterElement(xmldoc, clustername)
envElement = clusterElement.getElementsByTagName('environment')[0]
chefserver = envElement.getAttribute('chefserver')
if chefserver == None or chefserver == "" :
  chefserver = "localhost"


os.system('ntpdate '+chefserver+'')
nodelist=getNodeNames(clusterElement)
#serverdate = shell_eval('date +"%m%d%k%M%Y.%S"')

for node in nodelist:
  #os.system('ssh '+node+' "date '+serverdate+'"')
  command='ssh '+node+' "ntpdate '+chefserver+'"'
  print command 
  proc = subprocess.Popen(command, \
        shell=True, stderr=subprocess.PIPE, stdout=subprocess.PIPE)
  return_code = proc.wait()
  # Read from pipes
  for line in proc.stdout:
    print("stdout: " + line.rstrip())
  for line in proc.stderr:
    pass
    #print("stderr: " + line.rstrip())
