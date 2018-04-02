import asyncio
import websockets
import builtins as __builtin__
from .parser import parse
from .subscriber import Subscriber
import json
import threading
import urllib.request
import json
import urllib3
http = urllib3.PoolManager()

logs = []

class Storage():
    pass

subscriber = Subscriber()
storage = Storage()
storage.socket = None

async def sendText(text):
    try:
        r = http.request('POST', 'http://127.0.0.1:8765/post',
                         headers={'Content-Type': 'application/json'},
                         body=text)
    except Exception as e:
        __builtin__.original_print('send exception: ' + str(e))
    finally:
        pass

def send(text):
    if isinstance(text,dict):
        try:
            text = json.dumps(text)
        except Exception as e:
            __builtin__.original_print('json.dumps failed: ' + str(e))

    loop = None
    try:
        loop = asyncio.get_event_loop()
    except:
        pass
    if not loop:
        loop = asyncio.new_event_loop()
    if loop.is_running():
        def async_print(text):
            send(text)
        thread = threading.Thread(target=async_print, args=[text])
        thread.start()
        thread.join()
    else:
       loop.run_until_complete(sendText(text))

subscriber.send = send

def main():
    while True:
        message = urllib.request.urlopen("http://127.0.0.1:8765/grep").read()
        try:
            parse(message)
        except Exception as e:
            __builtin__.original_print('parse exc: ' + str(e))

def subscribe(command, handler):
    subscriber.subscribe(command, handler)

def sendCommandWithHandler(className, action, handler, args=[]):
    subscriber.setClassHandler(className, action, handler)
    send({'command': 'classAction', 'class': className, 'action':action, 'args':args})
    pass
