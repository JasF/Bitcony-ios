
#import <CoreFoundation/CoreFoundation.h>

@protocol WaitingDialog <NSObject>
- (void)showWaitingDialogWithMessage:(NSString *)message;
- (void)waitingDialogClose;
@end
