#!/usr/bin/env python

from xml.dom import minidom
import os,sys
"""
0  All attributes off ...
1  Bold (or Bright) .. or ..
4  Underline ...
5  Blink ..
7  Reverse ..
30 Black text
31 Red text
32 Green text
33 Yellow text
34 Blue text
35 Purple text
36 Cyan text
37 White text
40 Black background
41 Red background
42 Green background
43 Yellow background
44 Blue background
45 Purple background
46 Cyan background
47 White background
"""

'''
    get the root node of the xml
'''
def parsexml(filename):
    doc = minidom.parse(filename)
    root = doc.documentElement
    user_nodes = root.getElementsByTagName('node')
    return user_nodes

'''
    get value of the node in the xml
'''
def get_nodevalue(node,index=0):
    return node[index].childNodes[0].nodeValue.encode('utf-8','ignore')

'''
    get node
'''
def get_xmlnode(node,name):
    return node.getElementsByTagName(name) if node else []

'''
    read services of openstack on each node
'''
def get_role(file):
    node_list = parsexml(file)
    role_list = []
    for node in node_list:
        node_host = get_xmlnode(node,'hostname')
        node_service = get_xmlnode(node,'role')
        host = get_nodevalue(node_host)
        services = get_nodevalue(node_service)
        hostrole = {'host':host,'role':services}
        role_list.append(hostrole)
        '''
        for service in services:
            hostservice = {}
            hostservice = {'host':host,'service':service}
            service_list.append(hostservice)
        '''
    return role_list

def role_to_service(roles):

    roledict={"keystone":"openstack-keystone","glance":"openstack-glance-api","cinder-api":"openstack-cinder-api","cinder-scheduler":"openstack-cinder-scheduler","nova-api":"openstack-nova-api","nova-scheduler":"openstack-nova-scheduler","nova-conductor":"openstack-nova-conductor","quantum-server":"quantum-server","quantum-dhcp-agent":"quantum-dhcp-agent","nova-compute":"openstack-nova-compute"}
    services=[]
    for role in roles:
        if role in roledict.keys():
            if role == "glance":
                services.append("openstack-glance-registry")
            services.append(roledict[role])
    return services

'''
    change the result to colored
'''
def colored(text, color=None, on_color=None, attrs=None):
    fmt_str = '\x1B[;%dm%s\x1B[0m'
    if color is not None:
        text = fmt_str % (color, text)

    if on_color is not None:
        text = fmt_str % (on_color, text)

    if attrs is not None:
        for attr in attrs:
            text = fmt_str % (color, text)
    return text

def printError(msg):
    print colored(msg, color=31)

def printWarning(msg):
    print colored(msg, color=33)

def printInfo(msg):
    print colored(msg, color=32)

def printCheck(msg):
    print colored(msg, color=45)

def status_to_string(status):
    if status.find("running") > 0:
        return "active"
    elif status.find("stop") > 0:
        return "stopped"
    elif status.find("dead") > 0:
        return "dead"
    else:
        return "unknown"

def get_status(host,services):
    for service in services:
        cmd = "ssh -i /root/.ssh/id_rsa root@"+host+" service " +service+" status"
        result = os.popen(cmd).read().strip('\n')
        status = status_to_string(result)
        output = service + "  :  "+status
#        print output
        if status == "active":
            printInfo(output)
        elif status == "stopped":
            printWarning(output)
        elif status == "dead":
            printError(output)
        else:
            print output

if __name__ == "__main__":
    file = sys.argv[1]
    role_list = get_role(file)
    for hostrole in role_list:
        host = hostrole['host']
        roles = hostrole['role'].split(',')
        printCheck("====== check host "+host+" =====")
        service_list = role_to_service(roles)
        get_status(host,service_list)
