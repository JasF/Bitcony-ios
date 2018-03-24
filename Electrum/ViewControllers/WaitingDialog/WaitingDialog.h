
#import <CoreFoundation/CoreFoundation.h>

@protocol WaitingDialog <NSObject>
- (void)showWithMessage:(NSString *)message;
- (void)close;
@end
