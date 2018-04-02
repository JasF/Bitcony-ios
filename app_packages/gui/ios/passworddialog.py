import os
import sys
import threading
import traceback
from objc import managers
from objc import runloop

class PasswordDialogHandlerProtocol():
    def passwordDialogDone(self, password):
        self.dialog.done(password)

class PasswordDialog:
    def __init__(self, msg, callback):
        self.msg = msg
        self.callback = callback
        handler = PasswordDialogHandlerProtocol()
        handler.dialog = self
        self.dialog = managers.shared().createPasswordDialog()
        self.dialog.handler = handler
    
    def show(self):
        self.dialog.showPasswordDialogWithMessage(self.msg)

    def done(self, password):
        self.password = password
        if self.callback:
            self.callback(password)

