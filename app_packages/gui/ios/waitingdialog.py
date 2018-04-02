import os
import sys
import threading
import traceback
from objc import managers
from objc import runloop

class WaitingDialog:
    def __init__(self, parent, message, task, on_success=None, on_error=None):
        assert parent
        self.dialog = managers.shared().createWaitingDialog()
        self.dialog.showWaitingDialogWithMessage(message)
        
        def __task():
            try:
                r = task()
                if on_success:
                    self.dialog.waitingDialogClose()
                    on_success(r)
            except Exception as e:
                if on_error:
                    self.dialog.waitingDialogClose()
                    on_error([False, e])

        t = threading.Thread(target = __task)
        t.start()
        t.join()

    def wait(self):
        self.thread.wait()

    def on_accepted(self):
        self.thread.stop()
