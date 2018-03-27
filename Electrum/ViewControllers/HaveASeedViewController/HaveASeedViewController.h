//
//  HaveASeedViewController.h
//  Electrum
//
//  Created by Jasf on 20.03.2018.
//  Copyright © 2018 Freedom. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol HaveASeedHandlerProtocol <NSObject>
- (void)continueTapped:(NSString *)seed;
- (NSString *)seedType:(NSString *)seed;
@end

@interface HaveASeedViewController : UITableViewController
@property (strong, nonatomic) id<HaveASeedHandlerProtocol> handler;
@end
