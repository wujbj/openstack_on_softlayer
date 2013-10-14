#!/usr/bin/python

from xml.dom import minidom
import pprint
import sys
import os
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

def register_nodes(xml_filename, clustername_to_match):
  xmldoc = minidom.parse(xml_filename)
  clusterlist = xmldoc.getElementsByTagName('cluster')
  for cluster in clusterlist :
    clustername = cluster.attributes['name'].value
    if clustername != clustername_to_match :
      continue;
    softwarexmldoc = None
    environment = cluster.getElementsByTagName('environment')[0]
    softwarexmlfile = environment.getAttribute('softwarexml')
    if softwarexmlfile != None and softwarexmlfile != "" :
      softwarexmldoc = minidom.parse(softwarexmlfile)

    nodelist = cluster.getElementsByTagName('node')
    for node in nodelist :
      hostname = node.getElementsByTagName('hostname')[0].firstChild.nodeValue;
      # pprint.pprint(hostlist);
      # hostname = node.getElementsByTagName('hostname')[0].value;
      #role = node.getElementsByTagName('role')[0].firstChild.nodeValue;
      #role = role.replace("-","_",);
      #groupname = clustername + "_" + role;
      groupname = clustername + ",all";
      
      # determine the install_ip
      if (len(node.getElementsByTagName('install')) > 0) :
        install_ip = node.getElementsByTagName('install')[0].getAttribute('ip');
      else :
        # for legacy nodelist.xml without the <install> element
        install_ip = node.getElementsByTagName('install_ip')[0].firstChild.nodeValue;

      # Make sure the install_ip is added to the /etc/hosts 
      grep_check = shell_eval("grep -w \"" + hostname + "\"" + " /etc/hosts");
      if (grep_check.find(hostname) == -1) :
        os.system("echo '" + install_ip + " " + hostname + " ' >> /etc/hosts");
      else :
        os.system("sed -e 's/.* " + hostname + " .*/" + install_ip + " " + hostname + " /' -i /etc/hosts");

      # Make sure the osmgmt ip is added to the /etc/hosts if it differs from install_ip
      if len(node.getElementsByTagName('osmgmt')) > 0 :
          osmgmt_ip = node.getElementsByTagName('osmgmt')[0].getAttribute('ip')
          if osmgmt_ip != install_ip :
              osmgmt_hostname = hostname + "-osmgmt"
              grep_check = shell_eval("grep -w \"" + osmgmt_hostname + "\"" + " /etc/hosts");
              if (grep_check.find(osmgmt_hostname) == -1) :
                  os.system("echo '" + osmgmt_ip + " " + osmgmt_hostname + " ' >> /etc/hosts");
              else :
                  os.system("sed -e 's/.* " + osmgmt_hostname + " .*/" + osmgmt_ip + " " + osmgmt_hostname + " /' -i /etc/hosts");

      print "Group for " + hostname + " is " + groupname;
      os.system( "nodeadd " + hostname + " groups=" + clustername + ",all");

      # Need to determine the install interface early so the right mac-address can be pulled
      if len(node.getElementsByTagName('install')) > 0 :
          install_if = node.getElementsByTagName('install')[0].getAttribute('original_if');
          if (install_if == None or install_if == ""): 
              install_if = node.getElementsByTagName('install')[0].getAttribute('if');
          os.system( "chdef " + hostname + " primarynic=" + install_if );

      nodetype = node.getElementsByTagName('hwtype')[0].firstChild.nodeValue.lower();
      if nodetype == "blade" :
          # Need to fetch the blade index from AMM and the AMM value
          amm = node.getElementsByTagName('amm')[0].firstChild.nodeValue;
          bladeslot = node.getElementsByTagName('bladeslot')[0].firstChild.nodeValue;
          os.system( "chdef " + hostname + " mpa=" + amm + " id=" + bladeslot + " mgt=blade");
          install_mac = None
          if len(node.getElementsByTagName('install')) > 0 :
              install_mac = node.getElementsByTagName('install')[0].getAttribute('mac')
          if install_mac == None or install_mac == "" :
              # Use the getmacs command for now
              os.system( "getmacs " + hostname);
          else :
              os.system( "chdef " + hostname + " mac=" + install_mac )              
          # os.system( "rbootseq " + hostname + " net");  # Done later just before rinstall now

      elif nodetype == "idataplex" or nodetype == "imm-managed" :
          # Make sure the BMC's IP is added to the /etc/hosts if provided
          bmc = node.getElementsByTagName('bmc')[0].firstChild.nodeValue; # the bmc hostname
          bmc_ip = node.getElementsByTagName('bmc')[0].getAttribute('ip');
          if bmc_ip != None :
              grep_check = shell_eval("grep -w \"" + bmc + "\"" + " /etc/hosts");
              if (grep_check.find(bmc) == -1) :
                  os.system("echo '" + bmc_ip + " " + bmc + " ' >> /etc/hosts");
              else :
                  os.system("sed -e 's/.* " + bmc + " .*/" + bmc_ip + " " + bmc + " /' -i /etc/hosts");
          # Just need the bmc hostname at the xcat layer
          os.system( "chdef " + hostname + " bmc=" + bmc + " bmcport=0 " + " mgt=ipmi");
 
          # Go check if the mac attribute exists on the install element, and use it if it's there
          # otherwise we'll pull the mac using "rinv"
          install_mac = ""
          if len(node.getElementsByTagName('install')) > 0 :
              install_mac = node.getElementsByTagName('install')[0].getAttribute('mac')
          if install_mac == None or install_mac == "" :
              # assuming to fetch eth0 for now for install, may need to change in future based on install "if"
              install_mac = shell_eval("rinv " + hostname + " | grep \"MAC Address 1:\" | awk '{ print $5 }'")
          os.system( "chdef " + hostname + " mac=" + install_mac )

          os.system( "chdef " + hostname + " serialport=0 serialspeed=115200")
          # os.system( "rsetboot " + hostname + " net");  # Now done by install_cluster_os.py before "rinstall"

      elif nodetype == "kvm" :
          kvm_ele = node.getElementsByTagName('kvm')[0]
          numcpus = kvm_ele.getAttribute('cpus')
          memgb = kvm_ele.getAttribute('memory')
          disksize = kvm_ele.getAttribute('disksize') # only used when deploying in the install_cluster_os.py
          diskdir = kvm_ele.getAttribute('diskdir')
          kvmhost = kvm_ele.getAttribute('host')
          mac = kvm_ele.getAttribute('mac')
          nicbridge = kvm_ele.getAttribute('nicbridge')
          
          os.system( "chdef " + hostname + " mgt=kvm vmcpus=" + numcpus + " vmmemory=" + memgb + " vmstorage=dir://" + diskdir )
          if kvmhost != None :
              os.system( "chdef " + hostname + " vmhost=" + kvmhost )
          if mac != None :
              os.system( "chdef " + hostname + " mac=" + mac )
          os.system( "chdef " + hostname + " vmnics=" + nicbridge )
          os.system( "chdef " + hostname + " serialport=0 serialspeed=115200")
          os.system( "chdef " + hostname + " vmnicnicmodel=virtio") # virtio for network
          os.system( "chdef " + hostname + " vmstoragemodel=virtio") # virtio for storage  
        
      else : 
          print "Unrecognized nodetype of " + nodetype
          sys.exit(1);

      if len(node.getElementsByTagName('xcat_profile')) > 0 :
          xcat_profile = node.getElementsByTagName('xcat_profile')[0].firstChild.nodeValue;
      else :
          xcat_profile = "kvm";
      os.system( "chdef " + hostname + " profile=" + xcat_profile);

      if len(node.getElementsByTagName('install_os')) > 0 :
          os_name = node.getElementsByTagName('install_os')[0].firstChild.nodeValue;
      else :
          os_name = "rhels6.3";       # We default the install for RHEL6.3
      os.system( "chdef " + hostname + " os=" + os_name);

      os.system( "chdef " + hostname + " netboot=xnba arch=x86_64 nodetype=osi");
    
      # Add the ethernet configuration postbootscript
      os.system( "chdef -p " + hostname + " postbootscripts=install_python,config_eth_devices");

      if len(node.getElementsByTagName('xcat_postbootscripts')) > 0 :
          extra_postbootscripts= node.getElementsByTagName('xcat_postbootscripts')[0].firstChild.nodeValue;
          os.system( "chdef -p " + hostname + " postbootscripts=" + extra_postbootscripts);

      if len(node.getElementsByTagName('xcat_postscripts')) > 0 :
          extra_postscripts= node.getElementsByTagName('xcat_postscripts')[0].firstChild.nodeValue;
          os.system( "chdef -p " + hostname + " postscripts=" + extra_postscripts);


parser = OptionParser()
parser.add_option("-f", "--file", dest="filename",default="/etc/scpsetup/nodelist.xml",
                  help="import cluster definition xml from FILE", metavar="FILE")
parser.add_option("-c", "--cluster", dest="clustername", default="",
                  help="clustername in the xml to process")
(options, args) = parser.parse_args()

# default_xml="/etc/scpsetup/nodelist.xml"
xml_filename = options.filename;
clustername = options.clustername;
print "Using " + xml_filename + " as the cluster xml definition";
if clustername == "" :
  print "Must specify clustername";
  sys.exit(1);

os.system("mkdir -p /install/postscripts/scpsetup");
os.system("cp -f " + xml_filename + " /install/postscripts/scpsetup/nodelist.xml");

register_nodes(xml_filename, clustername)
os.system("makeconservercf");
os.system("makedhcp -a");
os.system("makedns -n");
