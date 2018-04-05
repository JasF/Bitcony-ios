import os
import sys
import threading
import traceback
from objc import managers
from objc import runloop

class TextFieldDialogHandler():
    def done(self, text):
        self.dialog.done(text)
    
    def doneWithServerAddress(self, components):
        if len(components) == 2:
            addr = str(components[0])
            port = str(components[1])
            if len(addr) and len(port):
                address = addr + ':' + port + ':s'
            else:
                address = ''
            self.dialog.doneWithServerAddress(address)

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
    
    def showServerAddressInput(self):
        self.dialog.showWithMessage(self.msg, placeholder=self.placeholder, serverAddress=True)

    def doneWithServerAddress(self, address):
        if self.callback:
            self.callback(address)

    def done(self, password):
        self.password = password
        if self.callback:
            self.callback(self.password)



