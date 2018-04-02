import os
import sys
import threading
import traceback
from objc import managers
from objc import runloop

class YesNoDialogHandlerProtocol():
    def yesNoDialogDone(self, result):
        self.dialog.done(result)

class YesNoDialog:
    def __init__(self, parent, msg, callback):
        self.parent = parent
        self.callback = callback
        self.msg = msg
        handler = YesNoDialogHandlerProtocol()
        handler.dialog = self
        self.dialog = managers.shared().createYesNoDialog()
        self.dialog.handler = handler
        self.runLoop = runloop.shared();
    
    def show(self):
        self.dialog.showYesNoDialogWithMessage(self.msg)
    
    def done(self, result):
        print('yesNo dialog result: ' + str(result))
        if self.callback:
            self.callback(result)
