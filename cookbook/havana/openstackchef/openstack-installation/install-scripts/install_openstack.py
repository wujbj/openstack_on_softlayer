#!/usr/bin/env python
# -*- coding: utf-8 -*-

#
# Author: Chen Zhiwei <zhiwchen@cn.ibm.com>
# TODO: Use try-except to catch and throw errors.
#

from xml.dom import minidom
from optparse import OptionParser
import os, sys, time, subprocess, iniparse 

COUNTER = {'TOTAL': 1}

def sleep(count):
    global COUNTER
    for i in range(count, 0, -1):
        sys.stderr.write('TIME SPENT %d SECONDS\r'% COUNTER['TOTAL'])
        COUNTER['TOTAL'] = COUNTER['TOTAL'] + 1
        time.sleep(1)
    return None

def option_parser():
    cur_dir = os.path.abspath(os.path.dirname(__file__))
    parser = OptionParser()

    parser.add_option("-f", "--xml-file", dest = "xml_file",
        help = "The cluster xml file",
        metavar = "FILE")

    parser.add_option("-r", "--ini-file", dest = "ini_file",
        default = cur_dir + os.sep + "roles.ini",
        help = "ini file name, Default: roles.ini",
        metavar = "FILE")

    parser.add_option("-e", "--env-tmpl", dest = "env_tmpl",
        default = cur_dir + os.sep + "environment.json.tmpl",
        help = "Environment template file, Default: \
                `environment.json.tmpl` in this script directory.",
        metavar = "FILE")

    parser.add_option("-n", "--cluster-name", dest = "cluster_name", default = "",
        help = "Cluster name you defined in xml file")

    parser.add_option("-E", "--create-environment", action = "store_true",
        dest = "create_environment", default = False,
        help = "Whether create the environment file")

    parser.add_option("-S", "--show-environment", action = "store_true",
        dest = "show_environment", default = False,
        help = "Whether show the environment file")

    parser.add_option("-U", "--upload-environment", action = "store_true",
        dest = "upload_environment", default = False,
        help = "Whether upload the environment file")

    parser.add_option("-R", "--upload-roles", action = "store_true",
        dest = "upload_roles", default = False,
        help = "Whether upload the chef roles")

    parser.add_option("-C", "--upload-cookbooks", action = "store_true",
        dest = "upload_cookbooks", default = False,
        help = "Whether upload the chef cookbooks")

    parser.add_option("", "--controller", action = "store_true",
        dest = "controller", default = False,
        help = "Whether bootstrap the controller nodes")

    parser.add_option("", "--cinder", action = "store_true",
        dest = "cinder", default = False,
        help = "Whether bootstrap the compute nodes")

    parser.add_option("", "--compute", action = "store_true",
        dest = "compute", default = False,
        help = "Whether bootstrap the compute nodes")

    parser.add_option("-B", "--bootstrap", action = "store_true",
        dest = "bootstrap", default = False,
        help = "Whether bootstrap all the cluster nodes")

    parser.add_option("-D", "--dry-run", action = "store_true",
        dest = "dry_run", default = False,
        help = "Whether perform a dry run by generating Chef commands")

    parser.add_option("-a", "--all", action = "store_true",
        dest = "all", default = False,
        help = "Do all the actions, create environment file, \
                upload environment file, roles, cookbooks and bootstrap nodes")

    options, _ = parser.parse_args()

    status = True
    if options.cluster_name == '':
        status = False
        print 'You must specify a cluster name!'

    if not os.path.exists(options.xml_file):
        status = False
        print 'Your xml file is not exist'

    if not os.path.exists(options.ini_file):
        status = False
        print 'Your roles info file(roles.ini) is not exist'

    if not os.path.exists(options.env_tmpl):
        status = False
        print 'Your environment template file is not exist'

    if not status:
        exit(1)

    return options

## ini_file: a .ini file
## return: ConfigParser object
def config_parser(ini_file):
    config = iniparse.ConfigParser()
    config.read(ini_file)
    section = 'DEFAULT'
    status = True
    if not config.has_section(section):
        status = False
        print ini_file + ': file has not `'+ section +'` section'

    elif not config.has_option(section, 'always'):
        status = False
        print ini_file + ': file has not `'+ section +':always` section'

    elif not config.has_option(section, 'order'):
        status = False
        print ini_file + ': file has not `'+ section +':order` section'

    if not status:
        exit(1)

    return config

## roles: role1,role2, role3,role2
## return: ['role1', 'role2', 'role3']
def get_list_from_string(roles):
    list = []
    roles = roles.split(',')
    for role in roles:
        role = role.strip()
        if role not in list and role != '':
            list.append(role)

    return list

## roles: ['role1', 'role2', 'role3']
## return: role[role1],role[role2],role[role3]
def get_string_from_list(roles):
    str = ''
    for role in roles:
        str = str + 'role[' + role + '],'

    return str.rstrip(',')

## role_list: ['role1', 'role3', 'role2']
## role_order: ['role1', 'role2', 'role3', 'role4']
## return: ['role1', 'role2', 'role3']
def get_order_list(role_list, role_order):
    order = []
    for role in role_order:
        if role in role_list:
            order.append(role)

    return order

## nodes_info: {'node1': ['role1', 'role2', 'role3'], 'node2': ['role2', 'role3', 'role4']}
## role: a role name
## return: a dict of nodes and roles
def get_nodes_info_by_role(nodes_info, role):
    dict = {}
    for node, roles in nodes_info.items():
        list = []
        if role in roles:
            for r in roles:
                list.append(r)
                if r == role:
                    break
            dict[node] = list

    return dict

## ini_file: a .ini file
## return: option list
def get_list_from_ini(ini_file, option):
    section = 'DEFAULT'
    config = config_parser(ini_file)
    return get_list_from_string(config.get(section, option))

## ini_file: a .ini file
## return: role order list
def get_order_list_from_ini(ini_file):
    order = get_list_from_ini(ini_file, 'always')
    config = config_parser(ini_file)
    set_list = get_list_from_ini(ini_file, 'order')
    for set in set_list:
        order = order + get_list_from_ini(ini_file, set)

    return order

## xml_file: a .xml file
## cluster_name: a string
## return: cluster xml object
def get_cluster_element(xml_file, cluster_name):
    xmldoc = minidom.parse(xml_file)
    cluster_list = xmldoc.getElementsByTagName('cluster')
    for cluster in cluster_list:
        name = cluster.attributes['name'].value
        if name == cluster_name:
            return cluster

    exit('Cluster name `' + cluster_name + '` is not found.')
    return None

## xml_file: a .xml file
## cluster_name: a string
## ini_file: a .ini file
## return: {'node1': ['role1', 'role2', 'role3'], 'node2': ['role2', 'role3','role4']}
def get_nodes_info(xml_file, cluster_name, ini_file):
    info = {}
    role_order = get_order_list_from_ini(ini_file)
    cluster = get_cluster_element(xml_file, cluster_name)
    nodelist = cluster.getElementsByTagName('node')
    for node in nodelist:
        hostname = node.getElementsByTagName('hostname')[0].firstChild.nodeValue;
        role = node.getElementsByTagName('role')[0].firstChild.nodeValue;
        info[hostname] = get_order_list(get_list_from_string(role), role_order)

    return info

## xml_file: a .xml file
## cluster_name: a string
## ini_file: a .ini file
def get_node_role_pair(xml_file, cluster_name, ini_file):
    cmd_list = []
    info = get_nodes_info(xml_file, cluster_name, ini_file)
    set_list = get_list_from_ini(ini_file, 'order')
    for set in set_list:
        run_dict = {}
        list = get_list_from_ini(ini_file, set)
        for role in list:
            run_dict = dict(run_dict.items() + get_nodes_info_by_role(info, role).items())

        cmd_list.append(run_dict)

    return cmd_list

## get command list
## keys in list is dict
def get_command_list(xml_file, cluster_name, ini_file):
    list = []
    cluster = get_cluster_element(xml_file, cluster_name)
    env = cluster.getElementsByTagName('environment')[0]
    env_name = env.getAttribute('env_name')
    username = env.getAttribute('username')
    ssh_key = env.getAttribute('ssh_key')

    cmd_list = get_node_role_pair(xml_file, cluster_name, ini_file)
    for cmd in cmd_list:
        dict = {}
        for node,roles in cmd.items():
            r = get_string_from_list(roles)
            c = 'knife bootstrap ' + node + ' -u ' + username \
                + ' -i ' + ssh_key + ' -d rhel -E ' + env_name + ' -r ' + r
            dict[node] = c
        list.append(dict)

    return list

def parallelize_run_command1(info):
    dict = {}
    for node, cmd in info.items():
        dict[node] = subprocess.Popen(cmd, shell=True, \
                stdout=subprocess.PIPE, stderr=subprocess.STDOUT)

    while True:
        for k,v in dict.items():
            out = v.stdout.read()
            if v.poll() is not None:
                code = v.returncode
                dict.pop(k)
                if code == 0:
                    print k + ': bootstrap success!'
                else:
                    print k + ': bootstrap failed!'

            path = cur_dir + os.sep + k + '.knife.log'
            open(path, 'a').write(out)

        if len(dict) == 0:
            break
        else:
            sleep(1)

def is_compute_node(info):
    flag = False
    for cmd in info.values():
        if 'nova-compute' in cmd:
            flag = True

        if 'cinder-volume' in cmd:
            return False
    return flag

def is_cinder_node(info):
    for cmd in info.values():
        if 'cinder-volume' in cmd:
            return True

    return False

## parallelize run commands
def parallelize_run_command(info):
    global COUNTER
    dict = {}
    for node, cmd in info.items():
        COUNTER[node] = 0
        f = open(node + '.knife.log', 'w')
        dict[node] = subprocess.Popen(cmd, shell=True, \
                stdout=f, stderr=subprocess.STDOUT)

    while True:
        for k,v in dict.items():
            COUNTER[k] = COUNTER[k] + 1
            if v.poll() is not None:
                code = v.returncode
                dict.pop(k)
                if code == 0:
                    print 'SUCCESS: TIME SPENT %d SECONDS' % COUNTER[k]
                    print info[k]
                    print ''
                else:
                    print 'FAILURE: TIME SPENT %d SECONDS' % COUNTER[k]
                    print 'PLEASE CHECK THE LOG FILE: %s.knife.log' % k
                    print info[k]
                    print ''
                    print 'TOTAL TIME SPENT %d SECONDS' % COUNTER['TOTAL']
                    exit(1)

        if len(dict) == 0:
            break
        else:
            sleep(1)

def get_element_attr_pair(e):
    dict = {}
    attrs = e.attributes
    for attr in attrs.items():
        dict[attr[0]] = attr[1]

    return dict

def get_element_node_pair(e):
    dict = {}
    for el in e:
        if el.nodeType == el.ELEMENT_NODE:
            if el.hasAttributes():
                dict.update(get_element_attr_pair(el))

            if el.hasChildNodes():
                if el.firstChild.nodeValue.strip() != '':
                    dict[el.nodeName] = el.firstChild.nodeValue
                dict.update(get_element_node_pair(el.childNodes))

    return dict

def get_environment_file(xml_file, cluster_name, env_tmpl):
    dict = {}
    cluster = get_cluster_element(xml_file, cluster_name)
    env_element = cluster.getElementsByTagName('environment')
    dict = get_element_node_pair(env_element)
    
    env_str = open(env_tmpl).read()

    for k,v in dict.items():
        env_str = env_str.replace('${'+k.upper()+'}', v)

    return env_str

def main():
    options = option_parser()
    xml_file = options.xml_file
    cluster_name = options.cluster_name
    env_tmpl = options.env_tmpl
    ini_file = options.ini_file
    create_environment = options.create_environment
    show_environment = options.show_environment
    upload_environment = options.upload_environment
    upload_roles = options.upload_roles
    upload_cookbooks = options.upload_cookbooks
    controller = options.controller
    compute = options.compute
    cinder = options.cinder
    bootstrap = options.bootstrap

    if bootstrap:
        controller = bootstrap

    dry_run = options.dry_run
    all = options.all

    if all:
        create_environment = True
        upload_environment = True
        upload_roles = True
        upload_cookbooks = True
        controller = True
        compute = True
        cinder = True
        bootstrap = True

    if dry_run:
        create_environment = False
        upload_environment = False
        upload_roles = False
        upload_cookbooks = False
        controller = False
        compute = False
        cinder = False

    ##############################################################
    cluster = get_cluster_element(xml_file, cluster_name)
    env = cluster.getElementsByTagName('environment')[0]
    env_name = env.getAttribute('env_name')
    path = env.getAttribute('path')
    env_path = path + os.sep + 'environment' + os.sep + env_name + '.json'
    env_str = get_environment_file(xml_file, cluster_name, env_tmpl)

    if create_environment:
        open(env_path, 'w').write(env_str)
        print "Created file: " + env_path

    if show_environment:
        print env_str
    ##############################################################

    ##############################################################
    upload_role_cmd = 'knife role from file ' + path \
                        + os.sep + 'roles' + os.sep + '*'

    delete_role_cmd = 'knife role list | xargs -i knife role delete -y {}'

    delete_cookbook_cmd = "knife cookbook list | awk '{print $1}' \
                            | xargs -i knife cookbook delete -y {}"

    upload_cookbook_cmd = 'knife cookbook upload --all -o ' \
                            + path + os.sep + 'cookbooks'

    upload_environment_cmd = 'knife environment from file ' + path \
                    + os.sep + 'environment' + os.sep + env_name + '.json'

    if upload_environment:
        print 'Will upload environment file'
        os.system(upload_environment_cmd)

    if upload_roles:
        print 'Will upload role files'
        os.system(delete_role_cmd)
        os.system(upload_role_cmd)

    if upload_cookbooks:
        print 'Will upload cookbooks'
        os.system(delete_cookbook_cmd)
        os.system(upload_cookbook_cmd)
    ##############################################################


    ##############################################################
    list = get_command_list(xml_file, cluster_name, ini_file)
    if dry_run:
        for info in list:
            if info:
                for k,v in info.items():
                     print v
                print ''
                print '========================'

    if controller:
        for info in list:
            if not is_compute_node(info) and not is_cinder_node(info) and info:
                parallelize_run_command(info)

    if compute:
        for info in list:
            if is_compute_node(info):
                parallelize_run_command(info)

    if cinder:
        for info in list:
            if is_cinder_node(info):
                parallelize_run_command(info)

    print 'TOTAL TIME SPENT %d SECONDS' % COUNTER['TOTAL']
    ##############################################################

if __name__ == '__main__':
    main()
