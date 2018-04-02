import os
import sys
import threading
import traceback
from objc import managers
from objc import runloop

class TextFieldDialogHandler():
    def done(self, text):
        self.dialog.done(text)

class TextFieldDialog:
    def __init__(self, msg, placeholder, callback):
        self.msg = msg
        self.placeholder = placeholder
        self.callback = callback
        handler = TextFieldDialogHandler()
        handler.dialog = self
        self.dialog = managers.shared().createTextFieldDialog()
        self.dialog.handler = handler

    def show(self):
        self.dialog.showWithMessage(self.msg, placeholder=self.placeholder)

    def done(self, password):
        self.password = password
        if self.callback:
            self.callback(self.password)



