#!/usr/bin/python

#test
from xml.dom import minidom
import pprint
import os
import sys
import subprocess
from optparse import OptionParser
import xml.etree.ElementTree as et

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

def getAppendNodeNames(clusterelement) :
  appendnodenamearray = []
  nodelist = clusterelement.getElementsByTagName('node')
  for node in nodelist :
    if(len(node.getElementsByTagName('append'))!=0):
      append=node.getElementsByTagName('append')[0].firstChild.nodeValue
      if append == 'true':
         hostname = node.getElementsByTagName('hostname')[0].firstChild.nodeValue;
         appendnodenamearray.append(hostname);
    else:
       continue	
  return appendnodenamearray;
  
def getAppendNodeLists(clusterelement) :
  appendnodelistarray = []
  nodelist = clusterelement.getElementsByTagName('node')
  for appendnodelist in nodelist :
    if(len(appendnodelist.getElementsByTagName('append'))!=0):
      append=appendnodelist.getElementsByTagName('append')[0].firstChild.nodeValue
      if append == 'true':
         appendnodelistarray.append(appendnodelist);
    else:
       continue	
  return appendnodelistarray;

parser = OptionParser()
parser.add_option("-f", "--file", dest="filename",default="/etc/scpsetup/nodelist.xml",
                  help="import cluster definition xml from FILE", metavar="FILE")
parser.add_option("-c", "--cluster", dest="clustername", default="",
                  help="clustername in the xml to process")

parser.add_option("-o", "--overwrite", action="store_true",dest="overwrite", default=False,
                  help="overwrite prior chef definitions")

(options, args) = parser.parse_args()

xml_filename = options.filename;
clustername = options.clustername;
overwrite_chef_definitions =options.overwrite;
if clustername == "" :
  print "Must specify clustername";
  sys.exit(1);

# Make sure the nodes are NTP sync'd

# the ntpdate program is a wimp if the target node time-delta is too big, must first force the date using date command
# before we can run ntpdate to sync them for later on
#serverdate = shell_eval('date +"%m%d%k%M%Y.%S"')
#iios.system("psh "+clustername+" \"date "+serverdate+"\"")
#os.system("psh "+clustername+" \"ntpserver=\`grep nameserver /etc/resolv.conf | awk '{print \$2}'\`; ntpdate \$ntpserver \"") 

# Hack required for bug in cinder recipes right now, which isn't creating this directory before using it
os.system("psh "+clustername+" \"mkdir -p /var/lib/cinder\"")

# Hack required for latest SCP cookbooks
os.system("psh "+clustername+" \"mkdir -p /opt/ibm/openstack/iaas/smartcloud/bin\"")

xmldoc = minidom.parse(xml_filename)
clusterElement = getClusterElement(xmldoc, clustername)
envElement = clusterElement.getElementsByTagName('environment')[0]
chefserver = envElement.getAttribute('chefserver')
if chefserver == None or chefserver == "" :
  chefserver = "localhost"
  
if overwrite_chef_definitions:
  overwrite_parm = "-o"
else:
  overwrite_parm =""
#NTP sync with chefserver
#os.system("psh "+clustername+" \"ntpdate \$chefserver \"") 
#nodelist=getNodeNames(clusterElement)

nodelist=getAppendNodeNames(clusterElement)

print "Start to stop NTP server...."
for node in nodelist:
  #os.system('ssh '+node+' "service ntpd"')
  command='ssh '+node+' "service ntpd"'
  print command
  proc = subprocess.Popen(command, \
        shell=True, stderr=subprocess.PIPE, stdout=subprocess.PIPE)
  return_code = proc.wait()
  # Read from pipes
  for line in proc.stdout:
    print("stdout: " + line.rstrip())
  for line in proc.stderr:
    print("stderr: " + line.rstrip())

print "Start to Sync the time..."
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
    print("stderr: " + line.rstrip())


print "Start to clean /etc/chef and /etc/yum.repos.d on target nodes...."
for node in nodelist:
  command=('ssh '+node+' "rm -rf /etc/chef"','ssh '+node+' "rm -rf /etc/yum.repos.d/*"','ssh '+node+' "rm -rf /etc/yum.repos.d/rhbl*')

  #print command

  for com in command:
    print com
    proc = subprocess.Popen(com, \
        shell=True, stderr=subprocess.PIPE, stdout=subprocess.PIPE)
    return_code = proc.wait()
    #print return_code
    # Read from pipes
    for line in proc.stdout:
       print("stdout: " + line.rstrip())
    for line in proc.stderr:
       pass
       #print("stderr: " + line.rstrip())

print "Start to create folder for cinder and smartcloud...."
for node in nodelist:
  command=('ssh '+node+' "mkdir -p /var/lib/cinder"','ssh '+node+' "mkdir -p /opt/ibm/openstack/iaas/smartcloud/bin"')
  #  Hack required for bug in cinder recipes right now, which isn't creating this directory before using it
  #os.system("psh "+clustername+" \"mkdir -p /var/lib/cinder\"")

  # Hack required for latest SCP cookbooks
  #os.system("psh "+clustername+" \"mkdir -p /opt/ibm/openstack/iaas/smartcloud/bin\"")

  #print command

  for com in command:
    print com
    proc = subprocess.Popen(com, \
        shell=True, stderr=subprocess.PIPE, stdout=subprocess.PIPE)
    return_code = proc.wait()
   # print return_code
    # Read from pipes
    for line in proc.stdout:
       print("stdout: " + line.rstrip())
    for line in proc.stderr:
      pass
      # print("stderr: " + line.rstrip())

if len(nodelist) == 0:
    print "No Append nodes are specified in nodelist.xml, Please check it"
    sys.exit(0)
#serverdate = shell_eval('date +"%m%d%k%M%Y.%S"')

print "Start to check if the Openstack is installed....."

for node in nodelist:
  #os.system("sp checkPkg.py root@"+node+":/tmp/")	
  print node
  command='ssh '+node+' "chkconfig --list|awk \'{print $1}\'|grep openstack"'
  print command
  proc = subprocess.Popen(command, \
        shell=True, stderr=subprocess.PIPE, stdout=subprocess.PIPE)
  return_code = proc.wait()
  print return_code
  
  # Read from pipes
  for line in proc.stdout:
    print("stdout: " + line.rstrip())
  for line in proc.stderr:
    print("stderr: " + line.rstrip())
	
  if (return_code == 0):
    print "The above openstack Packages are already Installed on "+node+", stop appending" 
    sys.exit(0)
	
os.system(sys.path[0]+"/knifecommandgenerator-append.py -f "+xml_filename+ " -c "+clustername+" "+overwrite_parm+" | tee "+clustername+"_append.log")
print("Now invoking the /tmp/"+clustername+"_appendrunall.sh on "+chefserver)
os.system("ssh root@"+chefserver+" /tmp/"+clustername+"_appendrunall.sh | tee -a "+clustername+"_append.log")

# Hack to get dhcp to work with some of the legacy cirros images (they need to see checksum on DHCP packets)
os.system("psh "+clustername+" \"service iptables status | grep CHECKSUM;if [ \$? -ne 0 ]; then iptables -A POSTROUTING -t mangle -p udp --dport 68 -j CHECKSUM --checksum-fill; fi\"")



print "remove append flag..."
os.system('cp /etc/scpsetup/nodelist.xml /etc/scpsetup/nodelist.bak.xml')

#Check if installation is success
status = dict()
for node in nodelist:
  #os.system("sp checkPkg.py root@"+node+":/tmp/")	
  print node

  command='ssh '+node+' "chkconfig --list|awk \'{print $1}\'|grep openstack"'
  #command='ssh '+node+' "yum list installed|grep openstack"'
  print command
  proc = subprocess.Popen(command, \
        shell=True, stderr=subprocess.PIPE, stdout=subprocess.PIPE)
  return_code = proc.wait()
  print return_code
  status[node]=return_code
  # Read from pipes
  for line in proc.stdout:
    print("stdout: " + line.rstrip())
  for line in proc.stderr:
    print("stderr: " + line.rstrip())

#Remove append TAG
print status
tree=et.parse(xml_filename)
root = tree.getroot()
#nodes = root.findall('cluster')
#node =nodes.find('node')
for cluster in root.findall('cluster'):
  nodes=cluster.find('nodes')
  for node in nodes.findall('node'):
    hostname = node.find('hostname').text
    if hostname in status:
          print hostname,status[hostname]
          if status[hostname] == 0:
             for append in node.findall('append'):
                node.remove(append)
tree.write(xml_filename)
