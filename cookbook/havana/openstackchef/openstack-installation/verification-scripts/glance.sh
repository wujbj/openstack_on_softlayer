#!/bin/sh

#source the variables
. ./common

########################################
# Check glance endpoints and bind_host
########################################

echo "########################################"
echo "Check glance endpoints and bind_host"
echo "########################################"

PUBLIC_GLANCE=`keystone endpoint-list | grep 9292 | awk '{print $6}' | awk -F 'http://' '{print $2}' | awk -F ':' '{print $1}'`
ADMIN_GLANCE=`keystone endpoint-list | grep 9292 | awk '{print $6}' | awk -F 'http://' '{print $2}' | awk -F ':' '{print $1}'`
INTERNAL_GLANCE=`keystone endpoint-list | grep 9292 | awk '{print $6}' | awk -F 'http://' '{print $2}' | awk -F ':' '{print $1}'`


PUBLIC_KEYSTONE=`keystone endpoint-list | grep 5000 | awk '{print $6}' | awk -F 'http://' '{print $2}' | awk -F ':' '{print $1}'`
ADMIN_KEYSTONE=`keystone endpoint-list | grep 5000 | awk '{print $6}' | awk -F 'http://' '{print $2}' | awk -F ':' '{print $1}'`
INTERNAL_KEYSTONE=`keystone endpoint-list | grep 5000 | awk '{print $6}' | awk -F 'http://' '{print $2}' | awk -F ':' '{print $1}'`


############################################################
# Check if glance and keystone endpoints IP addresses match
############################################################

if [ ${PUBLIC_GLANCE} != ${PUBLIC_KEYSTONE} ]; then
  echo "${WARNING} Glance and Keystone public endpoint IP addresses differ ${PUBLIC_GLANCE} ${PUBLIC_KEYSTONE}"
fi

if [ ${ADMIN_GLANCE} != ${ADMIN_KEYSTONE} ]; then
  echo "${WARNING} Glance and Keystone admin endpoint IP addresses differ ${ADMIN_GLANCE} ${ADMIN_KEYSTONE}"
fi

if [ ${INTERNAL_GLANCE} != ${INTERNAL_KEYSTONE} ]; then
  echo "${WARNING} Glance and Keystone internal endpoint IP addresses differ ${INTERNAL_GLANCE} ${INTERNAL_KEYSTONE}"
fi


############################################################
# Check if glance public and admin IP addresses match
############################################################
if [ ${PUBLIC_GLANCE} != ${ADMIN_GLANCE} ]; then
  echo "${INFO} Glance public and admin endpoints IP addresses DIFFER"
else
  echo "${INFO} Glance public and admin endpoints IP addresses MATCH"
fi


##############################################################
# Check where glance-api is listening and if that matches with
# the endpoint IP address
##############################################################

BIND_GLANCEAPI=`ssh -o LogLevel=quiet ${GLANCEIP} "grep bind_host /etc/glance/glance-api.conf" | awk '{print $3}'`

if [ ${BIND_GLANCEAPI} != "0.0.0.0" ]; then
  echo "${INFO} Glance API is listening on ${BIND_GLANCEAPI}. Access to glance-api outside this IP subnet will FAIL";

  #Check if bind_host matches public keystone endpoint
  if [ ${BIND_GLANCEAPI} != ${PUBLIC_GLANCE} ]; then
     echo "{WARNING} Glance public endpoint ${PUBLIC_GLANCE} is different from bind_host ${BIND_GLANCEAPI}. Accesses from public endpoint will FAIL"
  else
     echo "${INFO} Glance public endpoint ${PUBLIC_GLANCE} is same as bind_host ${BIND_GLANCEAPI}. Accesses from public endpoint will SUCCEED"
  fi
  
  #Check if bind_host matches admin keystone endpoint
  if [ ${BIND_GLANCEAPI} != ${ADMIN_GLANCE} ]; then
     echo "${WARNING} Glance public endpoint ${ADMIN_GLANCE} is different from bind_host ${BIND_GLANCEAPI}. Accesses from admin endpoint will FAIL"
  else
     echo "${INFO} Glance public endpoint ${ADMIN_GLANCE} is same as bind_host ${BIND_GLANCEAPI}. Accesses from admin endpoint will SUCCEED"
  fi

else
  echo "Glance is listening on ${BIND_GLANCEAPI}. Access to glance-api outside this IP subnet will SUCCEED"
fi
  

#############################################################
# Check where glance-registry is listening and if that matches with
# the endpoint IP address
##############################################################

BIND_GLANCEREGISTRY=`ssh -o LogLevel=quiet ${GLANCEIP} "grep bind_host /etc/glance/glance-registry.conf" | awk '{print $3}'`

if [ ${BIND_GLANCEREGISTRY} != "0.0.0.0" ]; then
  echo "${INFO} Glance registry is listening on ${BIND_GLANCEREGISTRY}. Access to glance-registry outside this IP subnet will FAIL";

  #Check if bind_host matches public keystone endpoint
  if [ ${BIND_GLANCEREGISTRY} != ${PUBLIC_GLANCE} ]; then
     echo "{WARNING} Glance public endpoint ${PUBLIC_GLANCE} is different from registry bind_host ${BIND_GLANCEREGISTRY}. Accesses from public endpoint will FAIL"
  else
     echo "${INFO} Glance public endpoint ${PUBLIC_GLANCE} is same as registry bind_host ${BIND_GLANCEREGISTRY}. Accesses from public endpoint will SUCCEED"
  fi

  #Check if bind_host matches admin keystone endpoint
  if [ ${BIND_GLANCEREGISTRY} != ${ADMIN_GLANCE} ]; then
     echo "${WARNING} Glance public endpoint ${ADMIN_GLANCE} is different from registry bind_host ${BIND_GLANCEREGISTRY}. Accesses from admin endpoint will FAIL"
  else
     echo "${INFO} Glance public endpoint ${ADMIN_GLANCE} is same as registry bind_host ${BIND_GLANCEAPI}. Accesses from admin endpoint will SUCCEED"
  fi

else
  echo "Glance registry is listening on ${BIND_GLANCEREGISTRY}. Access to glance-api outside this IP subnet will SUCCEED"
fi



