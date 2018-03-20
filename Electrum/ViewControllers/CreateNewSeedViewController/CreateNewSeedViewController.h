//
//  CreateNewSeedViewController.h
//  Electrum
//
//  Created by Jasf on 20.03.2018.
//  Copyright © 2018 Freedom. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CreateNewSeedHandlerProtocol <NSObject>
- (void)continueTapped:(id)aSelf;
- (NSString *)generatedSeed:(id)aSelf;
@end

@interface CreateNewSeedViewController : UIViewController
@property (strong, nonatomic) id<CreateNewSeedHandlerProtocol> handler;
@end
