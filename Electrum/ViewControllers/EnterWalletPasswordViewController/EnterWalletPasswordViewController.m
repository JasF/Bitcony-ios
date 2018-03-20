//
//  EnterWalletPasswordViewController.m
//  Electrum
//
//  Created by Jasf on 20.03.2018.
//  Copyright © 2018 Freedom. All rights reserved.
//

#import "EnterWalletPasswordViewController.h"

@interface EnterWalletPasswordViewController ()
@property (weak, nonatomic) IBOutlet UILabel *descriptionLabel;
@property (weak, nonatomic) IBOutlet UILabel *passwordLabel;
@property (weak, nonatomic) IBOutlet UILabel *repeatPasswordLabel;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UITextField *repeatPasswordTextField;
@property (weak, nonatomic) IBOutlet UIButton *continueButton;
@end

@implementation EnterWalletPasswordViewController

- (void)viewDidLoad {
    NSCParameterAssert(_handler);
    [super viewDidLoad];
    _descriptionLabel.text = L(_descriptionLabel.text);
    _passwordLabel.text = L(_passwordLabel.text);
    _repeatPasswordLabel.text = L(_repeatPasswordLabel.text);
    [_continueButton setTitle:L([_continueButton titleForState:UIControlStateNormal])
                     forState:UIControlStateNormal];
    
#ifdef DEBUG
    _passwordTextField.text = @"1";
    _repeatPasswordTextField.text = @"1";
#endif
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
- (IBAction)continueTapped:(id)sender {
    if ([_handler respondsToSelector:@selector(continueTapped:)]) {
        [_handler continueTapped:_passwordTextField.text];
    }
}

@end
