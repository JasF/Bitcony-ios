//
//  CreateWalletViewController.m
//  Electrum
//
//  Created by Jasf on 19.03.2018.
//  Copyright © 2018 Freedom. All rights reserved.
//

#import "CreateWalletViewController.h"

@interface CreateWalletViewController ()
@property (strong, nonatomic) IBOutlet UIButton *createNewSeedButton;
@property (strong, nonatomic) IBOutlet UIButton *haveASeedButton;
@property (strong, nonatomic) IBOutlet UILabel *descriptionLabel;
@end

@implementation CreateWalletViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)createNewSeedTapped:(id)sender {
    if ([_handler respondsToSelector:@selector(createNewSeedTapped:)]) {
        [_handler createNewSeedTapped:_handler];
    }
}

- (IBAction)haveASeedTapped:(id)sender {
    if ([_handler respondsToSelector:@selector(haveASeedTapped:)]) {
        [_handler haveASeedTapped:_handler];
    }
}

@end
