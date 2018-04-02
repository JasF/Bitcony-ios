//
//  CreateNewSeedViewController.h
//  Electrum
//
//  Created by Jasf on 20.03.2018.
//  Copyright © 2018 Freedom. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CreateNewSeedHandlerProtocol <NSObject>
- (void)continueTapped:(NSString *)newSeed;
- (NSString *)generatedSeed;
@end

@interface CreateNewSeedViewController : UITableViewController
@property (strong, nonatomic) id<CreateNewSeedHandlerProtocol> handler;
@end
