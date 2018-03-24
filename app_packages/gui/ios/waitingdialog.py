import os
import sys
import threading
import traceback
from rubicon.objc import ObjCClass, NSObject, objc_method

class WaitingDialog:
    def __init__(self, parent, message, task, on_success=None, on_error=None):
        assert parent
        Managers = ObjCClass("Managers")
        self.dialog = Managers.shared().createWaitingDialog()
        self.dialog.showWithMessage(message)
        
        def __task():
            try:
                task()
                if on_success:
                    self.dialog.close()
                    on_success('success')
            except Exception as e:
                if on_error:
                    self.dialog.close()
                    on_error(e)

        t = threading.Thread(target = __task)
        t.start()
        t.join()

    def wait(self):
        self.thread.wait()

    def on_accepted(self):
        self.thread.stop()
