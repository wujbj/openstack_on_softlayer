import thread
import time
import subprocess



output=""
# Define a function for the thread
def create_server(type, delay):
   count = 0
   handle =subprocess.Popen(command, shell=True,stdout=subprocess.PIPE)
   output= printhandle.communicate()[0] 

   while count < 5:
      time.sleep(delay)
      count += 1
      print "%s: %s" % ( threadName, time.ctime(time.time()) )

# Create two threads as follows
try:
   thread.start_new_thread( print_time, ("Thread-1", 2, ) )
   thread.start_new_thread( print_time, ("Thread-2", 4, ) )
except:
   print "Error: unable to start thread"

while 1:
   pass
