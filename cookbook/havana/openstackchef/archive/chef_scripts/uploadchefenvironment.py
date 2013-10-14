#!/usr/bin/python

# Script generator to generate chef environment file & output bash-script to execute knife commands to create cluster from nodelist.xml.
# This generated script should be executed on Chef Server using install_cluster_openstack that runs it as follows:
# knifecommandgenerator.sh nodelist.xml $clustername | ssh $chefserver "cat > /tmp/$clustername_runall.sh;chmod +x /tmp/$clustername_runall.sh;/tmp/runall.sh"

from xml.dom import minidom
import pprint
import os
import sys
import json
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

class MapParser:
  # The MapParser reads the chef-server's default-environment.map file to translate fields
  # from a nodelist.xml to the fields to replace in the default-environment.json 

  def __init__(self, localcheffile, localmapfile, clusterelement):
    self.mapline = []
    self.curr_item = None
    self.still_parsing = True
    self.xlate_index = 0
    self.clusterelement = clusterelement
    self.localmapfile = localmapfile
    self.localcheffile = localcheffile
    self.default_value = ""

  def _clustername(self) :
    sedmatch = self.mapline[self.xlate_index + 1]
    sedreplace = self.clusterelement.getAttribute('name')
    sedmatch = sedmatch.replace("$", "\$")  # escape any $'s
    sedreplace = sedreplace.replace("/", "\\/")  # escape any /'s
    os.system('sed "s/' + sedmatch + '/' + sedreplace + '/" -i ' + self.localcheffile)
    self.xlate_index = self.xlate_index + 2
    self.still_parsing = False

  def _default(self) :
    self.default_value = self.mapline[self.xlate_index + 1]
    self.xlate_index = self.xlate_index + 2

  def _element(self) :
    elementname = self.mapline[self.xlate_index + 1]
    elementarray = self.curr_item.getElementsByTagName(elementname)
    if len(elementarray) == 0 :
      raise Exception("No element of " + elementname + " found when parsing " + " ".join(self.mapline))
    self.xlate_index = self.xlate_index + 2
    self.curr_item = elementarray[0];
  
  def _attribute(self) :
    attributename = self.mapline[self.xlate_index + 1]
    sedmatch = self.mapline[self.xlate_index + 2]
    sedmatch = sedmatch.replace("$", "\$")  # escape any $'s
    sedreplace = self.curr_item.getAttribute(attributename)
    sedreplace = sedreplace.replace("/", "\\/")  # escape any /'s
    if sedreplace == "" :
      raise Exception("No attribute of " + attributename + " found when parsing " + " ".join(self.mapline))
    #print('going to run sed "s/' + sedmatch + '/' + sedreplace + '/" -i ' + self.localcheffile)
    os.system('sed "s/' + sedmatch + '/' + sedreplace + '/" -i ' + self.localcheffile)
    self.xlate_index = self.xlate_index + 3
    self.still_parsing = False

  def _value(self) :
    sedmatch = self.mapline[self.xlate_index + 1]
    sedreplace = self.curr_item.firstChild.nodeValue
    sedmatch = sedmatch.replace("$", "\$")  # escape any $'s
    sedreplace = sedreplace.replace("/", "\\/")  # escape any /'s
    #print('going to run:  sed "s/' + sedmatch + '/' + sedreplace + '/" -i ' + self.localcheffile)
    os.system('sed "s/' + sedmatch + '/' + sedreplace + '/" -i ' + self.localcheffile)
    self.xlate_index = self.xlate_index + 2
    self.still_parsing = False

  def _node_with_role(self) :
    nodelist = self.clusterelement.getElementsByTagName('node')
    rolename = self.mapline[self.xlate_index + 1]
    for node in nodelist :
      rolelist = node.getElementsByTagName('role')[0].firstChild.nodeValue.split(',')
      if not rolename in rolelist : 
        continue 
      self.curr_item = node
      self.xlate_index = self.xlate_index + 2
      return
    raise Exception("Could not find role " + rolename + " inside " + ",".join(rolelist))

  mapverbs = { "clustername" : _clustername,
             "default" : _default,
             "element" : _element,
             "attribute" : _attribute,
             "node_with_role" : _node_with_role,
             "value" : _value         
             }

  def apply_map_to_environment(self) :
    mf=open(localmapfile, 'r')
    end_of_mapfile = False
    while end_of_mapfile == False :
      mf_line = mf.readline()
      if mf_line == "" :
        end_of_mapfile = True
      else :
        self.curr_item = clusterelement
        self.xlate_index = 0
        self.mapline = mf_line.split()
        self.still_parsing = True
        self.default_value = ""
        #print(" # About to parse " + " ".join(self.mapline))
        try: 
          while self.still_parsing : 
            print("  # parsing verb " + self.mapline[self.xlate_index])
            self.mapverbs[self.mapline[self.xlate_index]](self)
        except : 
          if self.default_value != "" :
            sedmatch = self.mapline[len(self.mapline) - 1]  # last word in the line
            sedreplace = self.default_value
            sedmatch = sedmatch.replace("$", "\$")  # escape any $'s
            sedreplace = sedreplace.replace("/", "\\/")  # escape any /'s
            sedreplace = sedreplace.replace("$", "\$")  # escape any $'s too
            #print('going to run:  sed "s/' + sedmatch + '/' + sedreplace + '/" -i ' + self.localcheffile)
            os.system('sed "s/' + sedmatch + '/' + sedreplace + '/" -i ' + self.localcheffile)
            # self.still-parsing = False


def union(append_to, b):
    for ele in b:
        if ele not in append_to:
            append_to.append(ele)

def generate_knife_commands(localknifefile, localrolesfile, clusterelement, overwrite_chef_definitions) :
  
  # These two recipe definitions should be overwritten by contents of the localrolesfile
  # Note that in the recipe_order, the array positions designate where a sync is needed
  # among all the nodes (i.e. keystone & qpid can't be installed until mysql-master
  # has finished installing)
  recipe_order = [ "base,mysql-master",
                   "keystone,qpid",
                   "glance,nova-controller,cinder-controller",
                   "nova-compute,cinder-volume" ]
  prereq_table = {
   "base" : ["yum","base"],
   "mysql-master" : ["yum", "base", "mysql-master"],
   "keystone" : ["yum", "base", "mysql-master", "keystone"],
   "qpid" : ["yum","base","qpid"],
   "glance" : [ "yum", "base", "mysql-master", "qpid", "glance"],
   "nova-controller" : [ "yum", "base", "mysql-master", "qpid", "keystone", "nova-controller"],
   "cinder-controller" : [ "yum", "base", "mysql-master", "qpid", "keystone", "cinder-controller"],
   "nova-compute" : [ "yum", "base", "mysql-master", "qpid", "keystone", "nova-compute"],
   "cinder-volume" : [ "yum", "base", "mysql-master", "qpid", "keystone", "cinder-volume"],
  } 

  if os.path.exists(localrolesfile) :
    roles_fh = open(localrolesfile, 'r')
    # Now override them
    data = json.load(roles_fh)
    recipe_order = data["recipe_order"] 
    prereq_table = data["prereq_table"]
    roles_fh.close()

  knife_fh = open(localknifefile, 'w')
  knife_fh.write('#!/bin/bash\n\n')

  nodenames = getNodeNames(clusterelement);
  clustername = clusterelement.getAttribute('name')
  chefpath = clusterelement.getElementsByTagName('environment')[0].getAttribute('chefpath')
  if chefpath == None or chefpath == "" :
    chefpath = sys.path[0]+'/../openstack-installation'

  target_password = "wrong_password"
  # Get the root password from xCAT passwd table
  for line in shell_eval('tabdump passwd').split('\n') :
    # print("tabdump passwd line output: "+line)
    if line.split(',')[0] == '"system"' : 
      target_password = line.split(',')[2].replace('"','')

  domain_suffix = ""
  # Get the domain suffix from xCAT site table
  for line in shell_eval('tabdump site').split('\n') :
    # print("tabdump site line output: "+line)
    if line.split(',')[0] == '"domain"' :
      domain_suffix = line.split(',')[1].replace('"','')

  if overwrite_chef_definitions :
    for node in nodenames :
      knife_fh.write('printf \"Y\\n\" | knife node delete ' + node + '\n')  # for RHEL chef clients
      knife_fh.write('printf \"Y\\n\" | knife client delete ' + node + '\n')
      knife_fh.write('printf \"Y\\n\" | knife node delete ' + node + '.' + domain_suffix + '\n')  # for Ubuntu chef clients
      knife_fh.write('printf \"Y\\n\" | knife client delete ' + node + '.' + domain_suffix + '\n')
    knife_fh.write('printf \"Y\\n\" | knife environment delete ' + clustername + '\n' )

  knife_fh.write('cd '+chefpath+'/environment/ ; knife environment from file '+clustername+'.json \n')
  nodelist = clusterelement.getElementsByTagName('node')
  knife_fh.close()    


parser = OptionParser()
parser.add_option("-f", "--file", dest="filename",default="/etc/scpsetup/nodelist.xml",
                  help="import cluster definition xml from FILE", metavar="FILE")
parser.add_option("-c", "--cluster", dest="clustername", default="",
                  help="clustername in the xml to process")
parser.add_option("-o", "--overwrite", action="store_true", dest="overwrite", default=False,
                  help="overwrite prior chef definitions")
# TODO:  Add -n --nodes option for only performing the actions on a comma-separted list of node names

(options, args) = parser.parse_args()

xml_filename = options.filename;
clustername = options.clustername;
overwrite_chef_definitions = options.overwrite;
#print "Using " + xml_filename + " as the cluster xml definition";
if clustername == "" :
  print "Must specify clustername";
  sys.exit(1);
if clustername == "default-environment" :
  print "clustername of default-environment is reserved, please rename"
  sys.exit(1);

xmldoc = minidom.parse(xml_filename)
clusterelement = getClusterElement(xmldoc, clustername)
localknifefile = "/tmp/load_chefenv_"+clustername+".sh"

# generate the chef environment file using the template on the chef-server and the map files there
env_element = clusterelement.getElementsByTagName('environment')[0] 
chefserver = env_element.getAttribute('chefserver')
if chefserver == None or chefserver == "" :
  chefserver = "localhost"
chefpath = env_element.getAttribute('chefpath')
if chefpath == None or chefpath == "" :
  chefpath = sys.path[0]+"/../openstack-installation/"
print ("chefpath =" + chefpath)
localchefenvfile = "/tmp/" + clustername + ".json"
localrolesfile =  "/tmp/" + clustername + ".roles"

# Now generate the knifefile to run on the chef-server
generate_knife_commands(localknifefile, localrolesfile, clusterelement, overwrite_chef_definitions)
if chefserver != "localhost" :
  os.system("scp " + localchefenvfile + " root@"+chefserver+":"+chefpath+"/environment/"+clustername+".json");
  os.system("scp "+localknifefile+" root@"+chefserver+":"+localknifefile)
  os.system("ssh root@"+chefserver+" chmod 755 "+localknifefile)
  os.system("ssh root@"+chefserver+" '"+localknifefile +"'")
else :
  os.system("chmod 755 "+localknifefile)
  os.system(localknifefile)

