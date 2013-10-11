import time
import subprocess
import thread



output=[]
# Define a function for the thread
def create_server(hostname, delay):
   count = 0
   command ="./create_server.sh " + hostname
   handle =subprocess.Popen(command, shell=True,stdout=subprocess.PIPE)
   out= handle.communicate()[0]
   output.append(out)
   time.sleep(delay)
   print "%s: %s" % ( hostname, time.ctime(time.time()) )

# Create two threads as follows
thread.start_new_thread( create_server("bmctest01.privatecloud.ibm.com",6), ("Thread-1", 2, ) )
thread.start_new_thread( create_server("host01.privatecloud.ibm.com",1), ("Thread-2", 4, ) )

print output
