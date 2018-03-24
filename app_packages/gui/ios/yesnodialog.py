import os
import sys
import threading
import traceback
from rubicon.objc import ObjCClass, NSObject, objc_method

class YesNoHandler(NSObject):
    @objc_method
    def init_(self):
        return self
    
    @objc_method
    def done_(self, result):
        self.dialog.done(result)

class YesNoDialog:
    def __init__(self, parent, msg):
        self.parent = parent
        self.msg = msg
        handler = YesNoHandler.alloc().init()
        handler.dialog = self
        Managers = ObjCClass("Managers")
        self.dialog = Managers.shared().createYesNoDialog()
        self.dialog.handler = handler
        self.runLoop = ObjCClass("RunLoop").shared();
    
    def show(self):
        self.dialog.showWithMessage(self.msg)
        self.runLoop.exec()
        return self.result
    
    def done(self, result):
        print('result: ' + str(result))
        self.result = result
        self.runLoop.exit(0)


