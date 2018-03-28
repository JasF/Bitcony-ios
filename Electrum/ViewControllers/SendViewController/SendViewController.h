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

@protocol SendHandlerProtocol <NSObject>
- (void)viewDidLoad:(id)object;
- (void)previewTapped:(id)object;
- (void)feePosChanged:(NSNumber *)newPosition;
- (void)sendTapped:(id)object;
- (NSString *)baseUnit:(id)object;
@end

@protocol SendHandlerProtocolDelegate <NSObject>
- (NSString *)payToText;
- (NSString *)descriptionText;
- (NSString *)amountText;
@end

@interface SendViewController : UIViewController <SendHandlerProtocolDelegate>
@property (strong, nonatomic) id<SendHandlerProtocol> handler;
@property (strong, nonatomic) id<ScreensManager> screensManager;
@property (strong, nonatomic) id<AlertManager> alertManager;
@end
