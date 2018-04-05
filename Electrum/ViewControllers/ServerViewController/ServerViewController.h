//
//  ServerViewController.h
//  Electrum
//
//  Created by Jasf on 05.04.2018.
//  Copyright © 2018 Freedom. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PythonBridge.h"

@protocol ServerHandlerProtocol <NSObject>
- (void)changeServerNameTapped:(NSString *)currentServerName;
- (NSArray *)defaultServerList;
- (NSString *)customServerName;
- (NSNumber *)customServerActive;
- (void)setCustomServerActive:(NSNumber *)customServerActive;
@end

@protocol ServerHandlerProtocolDelegate <NSObject>
- (void)customServerNameUpdated:(NSString *)customServerName;
@end

@interface ServerViewController : UITableViewController
@property (strong, nonatomic) id<ServerHandlerProtocol> handler;
@property (strong, nonatomic) id<PythonBridge> pythonBridge;
@end
