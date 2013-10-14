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
parser.add_option("-o", "--overwrite", action="store_true", dest="overwrite", default=False,
                  help="overwrite prior chef definitions")
parser.add_option("-n", "--nodes", dest="nodenames", default="",
                  help="comma-separated list of subset of nodes in a cluster to do the install on")
parser.add_option("-p", "--preserve_env", action="store_true", dest="preserve_env", default=False,
                  help="preserve chef-environment values")

(options, args) = parser.parse_args()

xml_filename = options.filename
clustername = options.clustername
nodenames_filter = options.nodenames.split(',')
overwrite_chef_definitions = options.overwrite;
preserve_env = options.preserve_env
if clustername == "" :
  print "Must specify clustername";
  sys.exit(1);


xmldoc = minidom.parse(xml_filename)
clusterElement = getClusterElement(xmldoc, clustername)
envElement = clusterElement.getElementsByTagName('environment')[0]
chefserver = envElement.getAttribute('chefserver')
if chefserver == None or chefserver == "" :
  chefserver = "localhost"
if overwrite_chef_definitions :
  overwrite_parm = "-o "
else:
  overwrite_parm = ""
if preserve_env :
   preserve_parm = "-p "
else:
   preserve_parm = ""

# Make sure the nodes are NTP sync'd

# the ntpdate program is a wimp if the target node time-delta is too big, must first force the date using date command
# before we can run ntpdate to sync them for later on
serverdate = shell_eval('date +"%m%d%k%M%Y.%S"')
os.system("psh "+clustername+" \"date "+serverdate+"\"")
os.system("psh "+clustername+" \"ntpserver=\`grep nameserver /etc/resolv.conf | awk '{print \$2}'\`; ntpdate \$ntpserver \"") 

nodelist=getNodeNames(clusterElement)
print "Start to stop NTP server...."
for node in nodelist:
    #os.system('ssh '+node+' "service ntpd"')
    if nodenames_filter != None and node not in nodenames_filter :
        continue
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
    if nodenames_filter != None and node not in nodenames_filter :
        continue
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
    if nodenames_filter != None and node not in nodenames_filter :
        continue

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
#  Hack required for bug in cinder recipes right now, which isn't creating this directory before using it
for node in nodelist:
    if nodenames_filter != None and node not in nodenames_filter :
        continue
    command=('ssh '+node+' "mkdir -p /var/lib/cinder"','ssh '+node+' "mkdir -p /opt/ibm/openstack/iaas/smartcloud/bin"')
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


if options.nodenames == "" :
    os.system(sys.path[0]+"/knifecommandgenerator.py -f "+xml_filename+ " -c "+clustername+" "+overwrite_parm+preserve_parm+" | tee "+clustername+".log")
else :
    os.system(sys.path[0]+"/knifecommandgenerator.py -f "+xml_filename+ " -c "+clustername+" "+overwrite_parm+preserve_parm+" -n "+options.nodenames+" | tee "+clustername+".log")
    
print("Now invoking the /tmp/"+clustername+"_runall.sh on "+chefserver)
os.system("ssh root@"+chefserver+" /tmp/"+clustername+"_runall.sh | tee -a "+clustername+".log")

# Hack to get dhcp to work with some of the legacy cirros images (they need to see checksum on DHCP packets)
os.system("psh "+clustername+" \"service iptables status | grep CHECKSUM;if [ \$? -ne 0 ]; then iptables -A POSTROUTING -t mangle -p udp --dport 68 -j CHECKSUM --checksum-fill; fi\"")

# Hack to disable chef-client service on Ubuntu because apt-get chef installs the service we don't want...
# If the target systems are running Ubuntu, we need to force remove chef-client from being an active service and from the rc#.d since we
# don't want it running in the background, only when we use knife commands.
if "ubuntu" in clusterElement.getElementsByTagName('install_os')[0].firstChild.nodeValue :
  os.system("psh "+clustername+" \"update-rc.d -f chef-client remove\"")
  os.system("psh "+clustername+" \"service chef-client stop\"")

