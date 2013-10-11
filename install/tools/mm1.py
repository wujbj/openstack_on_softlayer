import time
import subprocess
import thread



output=""
output1=""
# Define a function for the thread
def create_com_server(hostname):
   count = 0
   command ="./create_server.sh " + hostname
   print command
   handle =subprocess.Popen(command, shell=True,stdout=subprocess.PIPE)
   output= handle.communicate()[0]
   print output  
   #print "%s: %s" % ( hostname, time.ctime(time.time()) )


def create_con_server(hostname):
   count = 0
   command1 ="./create_server.sh " + hostname
   print command1
   handle1 =subprocess.Popen(command, shell=True,stdout=subprocess.PIPE)
   output= handle1.communicate()[0]
   print output1  
  # print "%s: %s" % ( hostname, time.ctime(time.time()) )
# Create two threads as follows
try:
    thread.start_new_thread( create_com_server("bmctest01.privatecloud.ibm.com"), "Thread-1" )
    time.sleep(5)    
    thread.start_new_thread( create_con_server("host01.privatecloud.ibm.com"), "Thread-2" )
except:
    print "fail to start" 

print output
print output1
