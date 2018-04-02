//
//  SendViewController.h
//  Electrum
//
//  Created by Jasf on 22.03.2018.
//  Copyright © 2018 Freedom. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ScreensManager.h"
#import "AlertManager.h"
#import "PythonBridge.h"

@protocol SendHandlerProtocol <NSObject>
- (void)previewTapped:(id)object;
- (void)feePosChanged:(NSNumber *)newPosition;
- (void)sendTapped:(id)object;
- (NSString *)baseUnit:(id)object;
- (void)inputFieldsTexts:(NSArray *)texts;
@end

@protocol SendHandlerProtocolDelegate <NSObject>
- (void)requestInputFieldsTexts;
@end

@interface SendViewController : UIViewController <SendHandlerProtocolDelegate>
@property (strong, nonatomic) id<SendHandlerProtocol> handler;
@property (strong, nonatomic) id<ScreensManager> screensManager;
@property (strong, nonatomic) id<AlertManager> alertManager;
@property (strong, nonatomic) id<PythonBridge> pythonBridge;
@end
