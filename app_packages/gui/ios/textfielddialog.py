import os
import sys
import threading
import traceback
from rubicon.objc import ObjCClass, NSObject, objc_method

class TextFieldDialogHandler(NSObject):
    @objc_method
    def init_(self):
        return self

    @objc_method
    def done_(self, text):
        self.dialog.done(text)

class TextFieldDialog:
    def __init__(self, msg, placeholder):
        self.msg = msg
        self.placeholder = placeholder
        handler = TextFieldDialogHandler.alloc().init()
        handler.dialog = self
        Managers = ObjCClass("Managers")
        self.dialog = Managers.shared().createTextFieldDialog()
        self.dialog.handler = handler
        self.runLoop = ObjCClass("RunLoop").shared();

    def show(self):
        self.dialog.showWithMessage(self.msg, placeholder=self.placeholder)
        self.runLoop.exec()
        return self.password

    def done(self, password):
        self.password = password
        self.runLoop.exit(0)


