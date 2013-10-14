#!/bin/sh

#KEYSTONEIP="r2n19"
#INFO="[INFO] "
#WARNING="[WARNING] "
#ERROR="[ERROR] "
#SUCCESS="[SUCCESS] "

. ./common

########################################
# Check keystone endpoints and bind_host
########################################

echo "########################################"
echo "Check keystone endpoints and bind_host"
echo "########################################"

PUBLIC_KEYSTONE=`keystone endpoint-list | grep 5000 | awk '{print $6}' | awk -F 'http://' '{print $2}' | awk -F ':' '{print $1}'`
ADMIN_KEYSTONE=`keystone endpoint-list | grep 5000 | awk '{print $6}' | awk -F 'http://' '{print $2}' | awk -F ':' '{print $1}'`
INTERNAL_KEYSTONE=`keystone endpoint-list | grep 5000 | awk '{print $6}' | awk -F 'http://' '{print $2}' | awk -F ':' '{print $1}'`

if [ ${PUBLIC_KEYSTONE} != ${ADMIN_KEYSTONE} ]; then
  echo "${INFO} Keystone public and admin endpoints IP addresses DIFFER"
else
  echo "${INFO} Keystone public and admin endpoints IP addresses MATCH"
fi


BIND_KEYSTONE=`ssh -o LogLevel=quiet ${KEYSTONEIP} "grep bind_host /etc/keystone/keystone.conf" | awk '{print $3}'`

if [ ${BIND_KEYSTONE} != "0.0.0.0" ]; then
  echo "${INFO} Keystone is listening on ${BIND_KEYSTONE}. Access to keystone outside this IP subnet will FAIL";

  #Check if bind_host matches public keystone endpoint
  if [ ${BIND_KEYSTONE} != ${PUBLIC_KEYSTONE} ]; then
     echo "{WARNING} Keystone public endpoint ${PUBLIC_KEYSTONE} is different from bind_host ${BIND_KEYSTONE}. Accesses from public endpoint will FAIL"
  else
     echo "${INFO} Keystone public endpoint ${PUBLIC_KEYSTONE} is same as bind_host ${BIND_KEYSTONE}. Accesses from public endpoint will SUCCEED"
  fi
  
  #Check if bind_host matches admin keystone endpoint
  if [ ${BIND_KEYSTONE} != ${ADMIN_KEYSTONE} ]; then
     echo "${WARNING} Keystone public endpoint ${ADMIN_KEYSTONE} is different from bind_host ${BIND_KEYSTONE}. Accesses from admin endpoint will FAIL"
  else
     echo "${INFO} Keystone public endpoint ${ADMIN_KEYSTONE} is same as bind_host ${BIND_KEYSTONE}. Accesses from admin endpoint will SUCCEED"
  fi

else
  echo "Keystone is listening on ${BIND_KEYSTONE}. Access to keystone outside this IP subnet will SUCCEED"
fi
  



