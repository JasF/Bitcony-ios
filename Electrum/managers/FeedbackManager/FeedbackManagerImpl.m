//
//  FeedbackManagerImpl.m
//  Utilsscopes
//
//  Created by Jasf on 22.12.2017.
//  Copyright © 2017 Freedom. All rights reserved.
//

#import <MessageUI/MessageUI.h>
#import "FeedbackManagerImpl.h"

@interface UIDevice (Utils)
+ (CGFloat)utils_systemVersion;
@end

@implementation UIDevice (Utils)
+ (CGFloat)utils_systemVersion {
    static float systemVersion = 0.0f;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        systemVersion = [UIDevice currentDevice].systemVersion.floatValue;
    });
    
    return systemVersion;
}
@end

static NSString *const kFeedbackText = @"\n\n\n\n----------------------------------------------------\nPlease do not delete this information.\nVersion: %@ (%@)\nOS: %.1f";
static NSString *const kElectrumFeedbackCaption = @"Electrum iOS Feedback";

@interface FeedbackManagerImpl () <MFMailComposeViewControllerDelegate>
@property (strong, nonatomic) UIViewController *parentViewController;
@end

@implementation FeedbackManagerImpl

#pragma mark - Public Methods
- (void)showFeedbackController:(UIViewController *)parentViewController {
    if ([MFMailComposeViewController canSendMail]) {
        MFMailComposeViewController *controller = [self createFeedbackMailController];
        if (controller) {
            _parentViewController = parentViewController;
            [_parentViewController presentViewController:controller animated:YES completion:nil];
        }
    }
    else {
        NSString *path = [NSString
                          stringWithFormat:@"/&subject=%@&body=%@", kElectrumFeedbackCaption, [self getDefaultFeedbackTextBody]];
        NSURL *mailUrl = [[NSURL alloc] initWithScheme:@"mailto" host:@"electrumios@gmail.com?" path:path];
        [[UIApplication sharedApplication] openURL:mailUrl];
    }
    return;
}

#pragma mark -
- (MFMailComposeViewController *)createFeedbackMailController {
    NSString *str = [self getDefaultFeedbackTextBody];
    MFMailComposeViewController *controller = [[MFMailComposeViewController alloc] init];
    if (!controller) {
        return nil;
    }
    [controller setMailComposeDelegate:self];
    [controller setToRecipients:[NSArray arrayWithObject:@"electrumios@gmail.com"]];
    [controller setSubject:kElectrumFeedbackCaption];
    [controller setMessageBody:str isHTML:NO];
    controller.modalPresentationStyle = UIModalPresentationFormSheet;
    return controller;
}

- (NSString *)getDefaultFeedbackTextBody {
    NSString *token = @"";
    NSString *formatString = kFeedbackText;
    NSString * version = [[NSBundle mainBundle] objectForInfoDictionaryKey: @"CFBundleShortVersionString"];
    NSString * build = [[NSBundle mainBundle] objectForInfoDictionaryKey: (NSString *)kCFBundleVersionKey];
    NSMutableString *result = [[NSString stringWithFormat:formatString, version, build, [UIDevice utils_systemVersion]] mutableCopy];
    NSString *logs = @"";
    [result appendFormat:@"\n\n%@", logs];
    return result;
}

#pragma mark - MFMailComposeViewControllerDelegate
- (void)mailComposeController:(MFMailComposeViewController *)controller
          didFinishWithResult:(MFMailComposeResult)result
                        error:(nullable NSError *)error {
    @weakify(self);
    [controller dismissViewControllerAnimated:YES completion:^{
        @strongify(self);
        if (result == MFMailComposeResultSent && self.parentViewController) {
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:L(@"send_feedback_thanks") message:@"" preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *action = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
            [alert addAction:action];
            [self.parentViewController presentViewController:alert animated:YES completion:nil];
        }
        self.parentViewController = nil;
    }];
}

@end
