#!/bin/sh

#NOVAIP="r2n19"
#INFO="[INFO] "
#WARNING="[WARNING] "
#ERROR="[ERROR] "
#SUCCESS="[SUCCESS] "

. ./common

########################################
# Check nova compute
########################################

echo "########################################"
echo "Check nova compute configuration"
echo "########################################"

PUBLIC_NOVA=`keystone endpoint-list | grep 8774 | awk '{print $6}' | awk -F 'http://' '{print $2}' | awk -F ':' '{print $1}'`
ADMIN_NOVA=`keystone endpoint-list | grep 8774 | awk '{print $6}' | awk -F 'http://' '{print $2}' | awk -F ':' '{print $1}'`
INTERNAL_NOVA=`keystone endpoint-list | grep 8774 | awk '{print $6}' | awk -F 'http://' '{print $2}' | awk -F ':' '{print $1}'`


PUBLIC_KEYSTONE=`keystone endpoint-list | grep 5000 | awk '{print $6}' | awk -F 'http://' '{print $2}' | awk -F ':' '{print $1}'`
ADMIN_KEYSTONE=`keystone endpoint-list | grep 5000 | awk '{print $6}' | awk -F 'http://' '{print $2}' | awk -F ':' '{print $1}'`
INTERNAL_KEYSTONE=`keystone endpoint-list | grep 5000 | awk '{print $6}' | awk -F 'http://' '{print $2}' | awk -F ':' '{print $1}'`


GLANCEIP=`ssh ${COMPUTEIP} -o LogLevel=quiet "grep glance_api_servers /etc/nova/nova.conf" | awk -F '=' '{print $2}' | tr -d ' ' | awk -F ':' '{print $1}'`

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


QPIDCONFIP=`ssh ${COMPUTEIP} -o LogLevel=quiet "grep qpid_host /etc/nova/nova.conf" | awk -F '=' '{print $2}' | tr -d ' ' | awk -F ':' '{print $1}'`

if [ "${QPIDIP}" = "${QPIDCONFIP}" ]; then
  echo "${SUCCESS} configured qpid ip address matches with actual qpid ip address"
else
  echo "${ERROR} configured qpid ip address ${QPIDCONFIP} does not match with qpid id address ${QPIDIP}"
fi
