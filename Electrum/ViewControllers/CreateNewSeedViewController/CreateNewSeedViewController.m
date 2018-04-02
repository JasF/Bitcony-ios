//
//  CreateNewSeedViewController.m
//  Electrum
//
//  Created by Jasf on 20.03.2018.
//  Copyright © 2018 Freedom. All rights reserved.
//

#import "CreateNewSeedViewController.h"
#import "TextViewCell.h"
#import "ButtonCell.h"
#import "LabelCell.h"

typedef NS_ENUM(NSInteger, Rows) {
    TitleRow,
    TextViewRow,
    DescriptionRow,
    ContinueRow,
    RowsCount
};

@interface CreateNewSeedViewController ()
@end

@implementation CreateNewSeedViewController {
    NSString *_seed;
    NSString *_htmlDescription;
    TextViewCell *_descriptionCell;
}

- (void)viewDidLoad {
    NSCParameterAssert(_handler);
    [Analytics logEvent:@"CreateNewSeedScreenDidLoad"];
    [super viewDidLoad];
    self.view.backgroundColor = self.navigationController.view.backgroundColor;
    
    if ([_handler respondsToSelector:@selector(generatedSeed)]) {
        _seed = [_handler generatedSeed];
    }
    NSCAssert(_seed.length, @"seed must be non-nil");
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = 50.f;
    [self.tableView registerNib:[UINib nibWithNibName:@"ButtonCell" bundle:nil] forCellReuseIdentifier:@"ButtonCell"];
    [self.tableView registerNib:[UINib nibWithNibName:@"LabelCell" bundle:nil] forCellReuseIdentifier:@"LabelCell"];
    [self.tableView registerNib:[UINib nibWithNibName:@"TextViewCell" bundle:nil] forCellReuseIdentifier:@"TextViewCell"];
    
    _htmlDescription = [NSString stringWithFormat:@"<font size=\"6\" color=\"white\"><p>"\
                                                          "%@"\
                                                          "%@"\
                                                          "</p>"\
                                 "<b>%@:</b>"\
                                 "<ul>"\
                                 "<li>%@</li>"\
                                 "<li>%@</li>"\
                                 "<li>%@</li>"\
                                 "</ul></font>",
                                 [NSString stringWithFormat:L(@"Please save these %d words on paper (order is important). "), 12],
                                 L(@"This seed will allow you to recover your wallet in case of computer failure."),
                                 L(@"WARNING"),
                                 L(@"Never disclose your seed."),
                                 L(@"Never type it on a website."),
                                 L(@"Do not store it electronically.")
                                 ];
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

- (IBAction)continueTapped:(id)sender {
    dispatch_python(^{
        if ([_handler respondsToSelector:@selector(continueTapped:)]) {
            [_handler continueTapped:_seed];
        }
    });
}

#pragma mark - UITableViewDataSource
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *resultCell = nil;
    switch (indexPath.row) {
        case TitleRow: {
            LabelCell *cell = [tableView dequeueReusableCellWithIdentifier:@"LabelCell"];
            [cell setTitle:L(@"Your wallet generation seed is:")];
            resultCell = cell;
            break;
        }
        case TextViewRow: {
            TextViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TextViewCell"];
            [cell setTextViewText:_seed];
            [cell setEditingAllowed:NO];
            [cell setStyleWithTransparentBackground:NO];
            resultCell = cell;
            break;
        }
        case DescriptionRow: {
            resultCell = [self descriptionCell];
            break;
        }
        case ContinueRow: {
            ButtonCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ButtonCell"];
            [cell setTitle:L(@"Create a new seed")];
            [cell setDelimeterVisible:NO];
            @weakify(self);
            cell.tappedHandler = ^{
                @strongify(self);
                [self continueTapped:nil];
            };
            resultCell = cell;
            break;
        }
    }
    resultCell.selectionStyle = UITableViewCellSelectionStyleNone;
    return resultCell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return RowsCount;
}

#pragma mark - UITableViewDelegate
- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == DescriptionRow) {
        CGFloat height = [[self descriptionCell] desiredHeight:tableView.width];
        return height;
    }
    return UITableViewAutomaticDimension;
}

#pragma mark - Private Methods
- (TextViewCell *)descriptionCell {
    if (!_descriptionCell) {
        _descriptionCell = [[NSBundle mainBundle] loadNibNamed:@"TextViewCell" owner:nil options:nil].firstObject;
        [_descriptionCell setEditingAllowed:NO];
        [_descriptionCell setStyleWithTransparentBackground:YES];
        NSAttributedString *attributedString = [[NSAttributedString alloc]
                                                initWithData: [_htmlDescription dataUsingEncoding:NSUnicodeStringEncoding]
                                                options: @{ NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType }
                                                documentAttributes: nil
                                                error: nil];
        [_descriptionCell setAttributedString:attributedString];
    }
    return _descriptionCell;
}

@end
