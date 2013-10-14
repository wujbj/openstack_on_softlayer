import threading
import os
import sys

class create_server(threading.Thread):
    def __init__(self, num, hostname):
        threading.Thread.__init__(self)
        self.thread_num = num
        self.hostname = hostname
        self.thread_stop = False
        self.out = ""

    def run(self):
        self.out=os.popen("./create_server.sh "+self.hostname).readlines()
            
    def stop(self):
        return self.out


if __name__=="__main__":
    thread1 = create_server(1,sys.argv[1])
    thread2 = create_server(2, sys.argv[2])
    thread1.start()
    thread2.start()
    thread1.join()
    thread2.join()
    host01= thread1.stop()
    host02 = thread2.stop()
