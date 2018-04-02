import time, threading, traceback, base64
import urllib.parse

class DPrinter():
    def dprint(self, text):
        pass
dprinter = DPrinter()

def dprint(text):
    dprinter.dprint(text)

try:
    from objc import printpatch
    printpatch.init(dprint)
except Exception as e:
    print('print patching exception: ' + str(e))

launched = False
def performLaunch():
    launched = True
    try:
        import electrum_main
        electrum_main.launch()
    except Exception as e:
        print('fail launch: ' + str(e))
        traceback.print_stack()

try:
    import objcbridge
    
    def sendPrint(text):
        objcbridge.send({'command':'logging', 'value':base64.b64encode(text.encode()).decode("utf-8")})
    dprinter.dprint = sendPrint
    
    def startSessionHandler():
        if launched == False:
            performLaunch()
            
    
    objcbridge.subscribe('startSession', startSessionHandler)
    objcbridge.main()
except Exception as e:
    print('server exception: ' + str(e))

