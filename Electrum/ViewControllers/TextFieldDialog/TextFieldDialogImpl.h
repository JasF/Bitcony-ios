//
//  TextFieldDialogImpl.h
//  Electrum
//
//  Created by Jasf on 25.03.2018.
//  Copyright © 2018 Freedom. All rights reserved.
//

#import "TextFieldDialog.h"
#import "ScreensManager.h"

@protocol TextFieldDialogHandler <NSObject>
- (void)done:(NSString *)enteredText;
- (void)doneWithServerAddress:(NSArray *)addressComponents;
@end

@interface TextFieldDialogImpl : NSObject <TextFieldDialog>
@property (strong, nonatomic) id<TextFieldDialogHandler> handler;
- (id)initWithScreensManager:(id<ScreensManager>)screensManager;
@end
