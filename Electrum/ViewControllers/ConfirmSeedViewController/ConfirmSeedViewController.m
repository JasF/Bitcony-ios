//
//  ConfirmSeedViewController.m
//  Electrum
//
//  Created by Jasf on 20.03.2018.
//  Copyright © 2018 Freedom. All rights reserved.
//

#import "ConfirmSeedViewController.h"

@interface ConfirmSeedViewController ()
@property (weak, nonatomic) IBOutlet UILabel *descriptionLabel;
@property (weak, nonatomic) IBOutlet UITextView *textView;
@property (weak, nonatomic) IBOutlet UIButton *continueButton;
@end

@implementation ConfirmSeedViewController

- (void)viewDidLoad {
    NSCParameterAssert(_handler);
    [super viewDidLoad];
    _descriptionLabel.text = L(_descriptionLabel.text);
#ifdef DEBUG
    NSString *seed = [_handler generatedSeed:_handler];
    _textView.text = seed;
#endif
    [_continueButton setTitle:L([_continueButton titleForState:UIControlStateNormal])
                     forState:UIControlStateNormal];
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
        [_handler continueTapped:nil];
    }
}

@end
