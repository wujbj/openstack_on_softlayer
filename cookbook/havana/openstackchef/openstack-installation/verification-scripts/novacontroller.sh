#!/bin/sh

#NOVAIP="r2n19"
#INFO="[INFO] "
#WARNING="[WARNING] "
#ERROR="[ERROR] "
#SUCCESS="[SUCCESS] "

. ./common

########################################
# Check nova controller endpoints and bind_host
########################################

echo "########################################"
echo "Check nova controller endpoints and bind_host"
echo "########################################"

PUBLIC_NOVA=`keystone endpoint-list | grep 8774 | awk '{print $6}' | awk -F 'http://' '{print $2}' | awk -F ':' '{print $1}'`
ADMIN_NOVA=`keystone endpoint-list | grep 8774 | awk '{print $6}' | awk -F 'http://' '{print $2}' | awk -F ':' '{print $1}'`
INTERNAL_NOVA=`keystone endpoint-list | grep 8774 | awk '{print $6}' | awk -F 'http://' '{print $2}' | awk -F ':' '{print $1}'`

if [ ${PUBLIC_NOVA} != ${ADMIN_NOVA} ]; then
  echo "${INFO} Nova public and admin endpoints IP addresses DIFFER"
else
  echo "${INFO} Nova public and admin endpoints IP addresses MATCH"
fi


PUBLIC_KEYSTONE=`keystone endpoint-list | grep 5000 | awk '{print $6}' | awk -F 'http://' '{print $2}' | awk -F ':' '{print $1}'`
ADMIN_KEYSTONE=`keystone endpoint-list | grep 5000 | awk '{print $6}' | awk -F 'http://' '{print $2}' | awk -F ':' '{print $1}'`
INTERNAL_KEYSTONE=`keystone endpoint-list | grep 5000 | awk '{print $6}' | awk -F 'http://' '{print $2}' | awk -F ':' '{print $1}'`


############################################################
# Check if nova and keystone endpoints IP addresses match
############################################################

if [ ${PUBLIC_NOVA} != ${PUBLIC_KEYSTONE} ]; then
  echo "${WARNING} Nova and Keystone public endpoint IP addresses differ ${PUBLIC_NOVA} ${PUBLIC_KEYSTONE}"
fi

if [ ${ADMIN_NOVA} != ${ADMIN_KEYSTONE} ]; then
  echo "${WARNING} Nova and Keystone admin endpoint IP addresses differ ${ADMIN_NOVA} ${ADMIN_KEYSTONE}"
fi

if [ ${INTERNAL_NOVA} != ${INTERNAL_KEYSTONE} ]; then
  echo "${WARNING} Nova and Keystone internal endpoint IP addresses differ ${INTERNAL_NOVA} ${INTERNAL_KEYSTONE}"
fi



BIND_NOVA=`ssh -o LogLevel=quiet ${NOVACONTROLLERIP} "grep bind_host /etc/nova/nova.conf" | awk '{print $3}'`

if [ "${BIND_NOVA}" = "" ]; then
  echo "${INFO} No bind_host specified. Default for nova should be 0.0.0.0"
elif [ ${BIND_NOVA} != "0.0.0.0" ]; then
  echo "${INFO} Nova is listening on ${BIND_NOVA}. Access to keystone outside this IP subnet will FAIL";

  #Check if bind_host matches public keystone endpoint
  if [ ${BIND_NOVA} != ${PUBLIC_NOVA} ]; then
     echo "{WARNING} Nova public endpoint ${PUBLIC_NOVA} is different from bind_host ${BIND_NOVA}. Accesses from public endpoint will FAIL"
  else
     echo "${INFO} Nova public endpoint ${PUBLIC_NOVA} is same as bind_host ${BIND_NOVA}. Accesses from public endpoint will SUCCEED"
  fi
  
  #Check if bind_host matches admin keystone endpoint
  if [ ${BIND_NOVA} != ${ADMIN_NOVA} ]; then
     echo "${WARNING} Nova public endpoint ${ADMIN_NOVA} is different from bind_host ${BIND_NOVA}. Accesses from admin endpoint will FAIL"
  else
     echo "${INFO} Nova public endpoint ${ADMIN_NOVA} is same as bind_host ${BIND_NOVA}. Accesses from admin endpoint will SUCCEED"
  fi

else
  echo "Nova is listening on ${BIND_NOVA}. Access to keystone outside this IP subnet will SUCCEED"
fi
  

GLANCEIP=`ssh ${NOVACONTROLLERIP} -o LogLevel=quiet "grep glance_api_servers /etc/nova/nova.conf" | awk -F '=' '{print $2}' | tr -d ' ' | awk -F ':' '{print $1}'`

if [ "${GLANCEIP}" = "" ]; then
  echo "${ERROR} glance ip server not specified"
else
  FLAG=0
  if [ "${GLANCEIP}" = "${ADMIN_GLANCE}" ]; then
    echo "${INFO} glance server ip addres ${GLANCEIP} matches admin endpoint"
    FLAG=1
  fi
  if [ "${GLANCEIP}" = "${PUBLIC_GLANCE}" ]; then
    echo "${INFO} glance server ip addres ${GLANCEIP} matches public endpoint"
    FLAG=1
  fi

  if [ ${FLAG} = 0 ]; then
    echo "${ERROR} glance server ip address ${GLANCEIP} specified in nova.conf does not match with endpoint IP address. Did you configure environment correctly?"
  fi
fi

