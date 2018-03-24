import os
import sys
import threading
import traceback
from rubicon.objc import ObjCClass, NSObject, objc_method

class PasswordDialogHandler(NSObject):
    @objc_method
    def init_(self):
        return self
    
    @objc_method
    def done_(self, password):
        self.dialog.done(password)

class PasswordDialog:
    def __init__(self, parent, msg):
        self.parent = parent
        self.msg = msg
        handler = PasswordDialogHandler.alloc().init()
        handler.dialog = self
        Managers = ObjCClass("Managers")
        self.dialog = Managers.shared().createPasswordDialog()
        self.dialog.handler = handler
        self.runLoop = ObjCClass("RunLoop").shared();
    
    def show(self):
        print('showhosw')
        self.dialog.showWithMessage(self.msg)
        self.runLoop.exec()
        return self.password

    def done(self, password):
        self.password = password
        self.runLoop.exit(0)

