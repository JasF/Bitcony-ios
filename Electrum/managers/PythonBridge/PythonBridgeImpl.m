//
//  PythonBridgeImpl.m
//  Rubricon
//
//  Created by Jasf on 30.03.2018.
//  Copyright © 2018 Home. All rights reserved.
//

#import "PythonBridgeImpl.h"
#import "PythonBridgeHandler.h"
#import <objc/runtime.h>

@import SocketRocket;

NSString * const PXProtocolMethodListMethodNameKey = @"methodName";
NSString * const PXProtocolMethodListArgumentTypesKey = @"types";

static NSTimeInterval kReconnectionDelay = 0.5f;
static NSString * const kHostAddress = @"ws://127.0.0.1:8765";

@interface PythonBridgeImpl () <SRWebSocketDelegate>
@property (strong, nonatomic) NSMutableDictionary *handlers;
@property (strong, nonatomic) dispatch_queue_t queue;
@end

@implementation PythonBridgeImpl {
    SRWebSocket *_webSocket;
    ResultBlock _resultBlock;
}

+ (instancetype)shared {
    static PythonBridgeImpl *shared = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shared = [PythonBridgeImpl new];
    });
    return shared;
}

- (id)init {
    if (self = [super init]) {
        _handlers = [NSMutableDictionary new];
        _queue = dispatch_queue_create("python.bridge.queue.serial", DISPATCH_QUEUE_SERIAL);
    }
    return self;
}

- (void)send:(NSDictionary *)object {
    NSData *data = [NSJSONSerialization dataWithJSONObject:object options:0 error:nil];
    dispatch_async(_queue, ^{
        [_webSocket send:data];
    });
}

- (void)connect {
    dispatch_async(_queue, ^{
        _webSocket = [[SRWebSocket alloc] initWithURL:[NSURL URLWithString:kHostAddress]];
        [_webSocket setDelegateDispatchQueue:self.queue];
        _webSocket.delegate = self;
        [_webSocket open];
    });
}

- (void)reconnect {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(kReconnectionDelay * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self connect];
    });
}

- (id)handlerWithActions:(NSDictionary *)actions
                    name:(NSString *)name {
    NSCParameterAssert(actions.count);
    return [[PythonBridgeHandler alloc] initWithPythonBridge:self
                                                        name:name
                                                     actions:actions];
}

- (void)sendAction:(NSString *)action
         className:(NSString *)className
         arguments:(NSArray *)arguments
        withResult:(BOOL)withResult
       resultBlock:(ResultBlock)resultBlock {
    NSCParameterAssert(action);
    NSCParameterAssert(className);
    if (!action || !className) {
        return;
    }
    if (resultBlock) {
        _resultBlock = resultBlock;
    }
    [self send:@{@"command":@"classAction", @"action":action, @"class":className, @"args":(arguments) ?: @[], @"withResult":@(withResult)}];
}

NSArray *px_allProtocolMethods(Protocol *protocol)
{
    NSMutableArray *methodList = [[NSMutableArray alloc] init];
    
    // We have 4 permutations as protocol_copyMethodDescriptionList() takes two BOOL arguments for the types of methods to return.
    for (NSUInteger i = 0; i < 4; ++i) {
        unsigned int numberOfMethodDescriptions = 0;
        struct objc_method_description *methodDescriptions = protocol_copyMethodDescriptionList(protocol, (i / 2) % 2, i % 2, &numberOfMethodDescriptions);
        
        for (unsigned int j = 0; j < numberOfMethodDescriptions; ++j) {
            struct objc_method_description methodDescription = methodDescriptions[j];
            [methodList addObject:@{PXProtocolMethodListMethodNameKey: NSStringFromSelector(methodDescription.name),
                                    PXProtocolMethodListArgumentTypesKey: [NSString stringWithUTF8String:methodDescription.types]}];
        }
        
        free(methodDescriptions);
    }
    
    return methodList;
}

- (id)handlerWithProtocol:(Protocol *)protocol {
    NSCParameterAssert(protocol);
    NSArray *methods = px_allProtocolMethods(protocol);
    NSMutableDictionary *actions = [NSMutableDictionary new];
    for (NSDictionary *dictionary in methods) {
        [actions setObject:dictionary[PXProtocolMethodListArgumentTypesKey]
                    forKey:dictionary[PXProtocolMethodListMethodNameKey]];
    }
    return [self handlerWithActions:[actions copy] name:NSStringFromProtocol(protocol)];
}

#pragma mark - SRWebSocketDelegate
- (void)webSocket:(SRWebSocket *)webSocket didReceiveMessage:(id)message {
    if ([message isKindOfClass:[NSString class]]) {
        message = [message dataUsingEncoding:NSUTF8StringEncoding];
    }
    NSDictionary *object = [NSJSONSerialization JSONObjectWithData:message options:0 error:nil];
    NSString *value = [self loggingStringWithDictionary:object];
    if (value) {
        NSLog(@"%@", value);
    }
    else {
        NSString *command = object[@"command"];
        if ([command isEqualToString:@"classAction"]) {
            [self performAction:object[@"action"] className:object[@"class"] args:object[@"args"]];
        }
        else if ([command isEqualToString:@"response"]) {
            id result = object[@"result"];
            if ([result isKindOfClass:[NSNull class]]) {
                result = nil;
            }
            NSCAssert(_resultBlock, @"received response but callback not achived!");
            if (_resultBlock) {
                ResultBlock block = _resultBlock;
                _resultBlock = nil;
                block(result);
            }
        }
        else {
            NSLog(@"unknown command. data: %@", object);
        }
    }
}

- (void)webSocketDidOpen:(SRWebSocket *)webSocket {
    NSLog(@"webSocketDidOpen");
    [self send:@{@"command":@"startSession"}];
    //[self cycle];
}

- (void)cycle {
    //[self send];
    //[self performSelector:@selector(cycle) withObject:nil afterDelay:2];
}

- (void)webSocket:(SRWebSocket *)webSocket didFailWithError:(NSError *)error {
    NSLog(@"didFailWithError: %@", error);
    [self reconnect];
}

- (void)webSocket:(SRWebSocket *)webSocket didCloseWithCode:(NSInteger)code reason:(NSString *)reason wasClean:(BOOL)wasClean {
    NSLog(@"didCloseWithCode: %@, reason: %@", @(code), reason);
    [self reconnect];
}

- (void)webSocket:(SRWebSocket *)webSocket didReceivePong:(NSData *)pongPayload {
    NSLog(@"webSocket:didReceivePong: %@", pongPayload);
}

// Return YES to convert messages sent as Text to an NSString. Return NO to skip NSData -> NSString conversion for Text messages. Defaults to YES.
- (BOOL)webSocketShouldConvertTextFrameToString:(SRWebSocket *)webSocket; {
    return YES;
}

#pragma mark - Private
- (NSString *)loggingStringWithDictionary:(NSDictionary *)object {
    if ([object isKindOfClass:[NSDictionary class]]) {
        NSString *command = object[@"command"];
        if ([command isEqualToString:@"logging"]) {
            NSData *data = [[NSData alloc] initWithBase64EncodedString:(NSString *)object[@"value"] options:0];
            NSString *string = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            return string;
        }
    }
    return nil;
}

- (void)performAction:(NSString *)action
            className:(NSString *)className
                 args:(NSArray *)args {
    NSCParameterAssert(action);
    NSCParameterAssert(className);
    if (!action || !className) {
        return;
    }
    id handler = _handlers[className];
    if (!handler) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self performAction:action className:className args:args];
        });
        return;
    }
    SEL selector = NSSelectorFromString(action);
    if (!args.count) {
        [self performSelector:selector onHandler:handler];
    }
    else if (args.count == 1) {
        [self performSelector:selector onHandler:handler arg1:args[0]];
    }
    else if (args.count == 2) {
        [self performSelector:selector onHandler:handler arg1:args[0] arg2:args[1]];
    }
}

- (void)performSelector:(SEL)selector onHandler:(id)handler {
    NSCParameterAssert(handler);
    if (!handler) {
        return;
    }
    IMP imp = [handler methodForSelector:selector];
    void (*func)(id, SEL) = (void *)imp;
    func(handler, selector);
}

- (void)performSelector:(SEL)selector onHandler:(id)handler arg1:(id)arg1 {
    NSCParameterAssert(handler);
    if (!handler) {
        return;
    }
    IMP imp = [handler methodForSelector:selector];
    void (*func)(id, SEL, id) = (void *)imp;
    func(handler, selector, arg1);
}

- (void)performSelector:(SEL)selector onHandler:(id)handler arg1:(id)arg1 arg2:(id)arg2 {
    NSCParameterAssert(handler);
    if (!handler) {
        return;
    }
    IMP imp = [handler methodForSelector:selector];
    void (*func)(id, SEL, id, id) = (void *)imp;
    func(handler, selector, arg1, arg2);
}

- (void)setClassHandler:(id)handler
                   name:(NSString *)className {
    NSCParameterAssert(className);
    NSCParameterAssert(handler);
    [_handlers setObject:handler forKey:className];
}

@end
