controller_name="bmctest01.privatecloud.ibm.com"
compute_name="bmctest05.privatecloud.ibm.com"
./create_server.sh $controller_name $compute_name
sresult=`sed -n '1p' new_server`
cresult=`sed -n '2p' new_server`
#sresult=`./create_server $controller_name`
#sresult="10.66.222.216 root 119.81.66.35"
sip=`echo $sresult | awk -F ' ' '{print $1}' `
spassword=`echo $sresult | awk -F ' ' '{print $2}' `
spip=`echo $sresult | awk -F ' ' '{print $3}' `
echo $sip $spassword $spip
#sleep 10

#echo "Step 2: Provision a compute server use SoftLayer API "
#echo
#cresult=`./create_server $compute_name`
#cresult="10.66.222.226 ZXF6cqaP 119.81.66.40"
cip=`echo $cresult | awk -F ' ' '{print $1}' `
cpassword=`echo $cresult | awk -F ' ' '{print $2}' `
cpip=`echo $cresult | awk -F ' ' '{print $3}' `
echo $cip $cpassword $cpip
#sleep 10
