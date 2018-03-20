//
//  CreateNewSeedViewController.m
//  Electrum
//
//  Created by Jasf on 20.03.2018.
//  Copyright © 2018 Freedom. All rights reserved.
//

#import "CreateNewSeedViewController.h"

@interface CreateNewSeedViewController ()
@property (weak, nonatomic) IBOutlet UILabel *generationDescriptionLabel;
@property (weak, nonatomic) IBOutlet UILabel *seedDescriptionLabel;
@property (weak, nonatomic) IBOutlet UILabel *generationWarningLabel;
@property (weak, nonatomic) IBOutlet UILabel *generationWarningDescriptionLabel;
@property (weak, nonatomic) IBOutlet UITextView *textView;
@property (weak, nonatomic) IBOutlet UIButton *continueButton;
@end

@implementation CreateNewSeedViewController

- (void)viewDidLoad {
    NSCParameterAssert(_handler);
    [super viewDidLoad];
    
    NSString *seed = nil;
    if ([_handler respondsToSelector:@selector(generatedSeed:)]) {
        seed = [_handler generatedSeed:_handler];
    }
    NSCAssert(seed.length, @"seed must be non-nil");
    _generationDescriptionLabel.text = L(_generationDescriptionLabel.text);
    _seedDescriptionLabel.text = L(_seedDescriptionLabel.text);
    _generationWarningLabel.text = L(_generationWarningLabel.text);
    _generationWarningDescriptionLabel.text = L(_generationWarningDescriptionLabel.text);
    [_continueButton setTitle:L([_continueButton titleForState:UIControlStateNormal])
                     forState:UIControlStateNormal];
    _textView.text = seed;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
#if AUTO_FORWARD == 1
    [self continueTapped:nil];
#endif
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
        [_handler continueTapped:self.textView.text];
    }
}

@end
