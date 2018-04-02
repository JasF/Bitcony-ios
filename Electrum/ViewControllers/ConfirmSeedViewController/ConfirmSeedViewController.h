//
//  ConfirmSeedViewController.h
//  Electrum
//
//  Created by Jasf on 20.03.2018.
//  Copyright © 2018 Freedom. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ConfirmSeedHandlerProtocol <NSObject>
- (NSString *)generatedSeed;
- (void)continueTapped:(id)object;
@end

@interface ConfirmSeedViewController : UITableViewController
@property (strong, nonatomic) id<ConfirmSeedHandlerProtocol> handler;
@end
