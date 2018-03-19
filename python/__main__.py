import threading
from util import printError
from util import DaemonThread

def MyThread1():
    print('MyThread1');
    pass

from rubicon.objc import ObjCClass
daemonThread = DaemonThread(threading.Thread, printError)
print(daemonThread)
print('Hello Python on iOS!')
HelloRubicon = ObjCClass("HelloRubicon")
NSURL = ObjCClass("NSURL")
base = NSURL.URLWithString("http://pybee.org/")
print(base)
obj = HelloRubicon.alloc().init();
print(obj)
