#
# Cookbook Name:: db2
# Recipe:: odbc
#
# Copyright 2013, IBM
#
# All rights reserved - Do Not Redistribute
#

db2_odbc "install db2 odbc driver" do
#    odbc_url            node['db2']['odbc_url']
    odbc_packages       node['db2']['odbc_packages']
    odbc_install_dir    node['db2']['odbc_install_dir']
    odbc_req_packages   node['db2']['odbc_req_packages']
    action :install
end
