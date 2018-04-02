import asyncio
import websockets
import builtins as __builtin__
from .parser import parse
from .subscriber import Subscriber
import json
import threading

logs = []

class Storage():
    pass

subscriber = Subscriber()
storage = Storage()
storage.socket = None

def processMessage():
    forSend = list(logs)
    del logs[:]
    result = str.encode(str(forSend))
    return result

async def echo(websocket, path):
    storage.socket = websocket
    if len(logs):
        forSend = list(logs)
        del logs[:]
        for string in forSend:
            await websocket.send(string)
    while True:
        try:
            message = await websocket.recv()
        except websockets.ConnectionClosed:
            storage.socket = None
            __builtin__.original_print('websockets.ConnectionClosed')
            break
        else:
            try:
                parse(message)
            except Exception as e:
                __builtin__.original_print('parse exc: ' + str(e))

async def sendText(text):
    if storage.socket:
        try:
            await storage.socket.send(str.encode(text))
        except Exception as e:
            __builtin__.original_print('send exception: ' + str(e))
        finally:
            pass
    else:
        pass

def send(text):
    if isinstance(text,dict):
        try:
            text = json.dumps(text)
        except Exception as e:
            __builtin__.original_print('json.dumps failed: ' + str(e))

    if storage.socket:
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
    else:
        logs.append(text)

subscriber.send = send

def main():
    eventLoop = asyncio.get_event_loop()
    eventLoop.run_until_complete(websockets.serve(echo, '127.0.0.1', 8765))
    eventLoop.run_forever()

def subscribe(command, handler):
    subscriber.subscribe(command, handler)

def sendCommandWithHandler(className, action, handler, args=[]):
    subscriber.setClassHandler(className, action, handler)
    send({'command': 'classAction', 'class': className, 'action':action, 'args':args})
    pass
