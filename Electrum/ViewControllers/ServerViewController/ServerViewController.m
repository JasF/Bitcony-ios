//
//  ServerViewController.m
//  Electrum
//
//  Created by Jasf on 05.04.2018.
//  Copyright © 2018 Freedom. All rights reserved.
//

#import "ServerViewController.h"
#import "LabelCell.h"

@interface ServerViewController () <UITableViewDelegate, UITableViewDataSource, ServerHandlerProtocolDelegate>
@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentedControl;
@property (weak, nonatomic) IBOutlet UIButton *rightButton;
@end

@implementation ServerViewController {
    NSArray *_serversList;
    NSString *_customServerName;
}

- (void)viewDidLoad {
    NSCParameterAssert(_handler);
    NSCParameterAssert(_pythonBridge);
    [super viewDidLoad];
    [_pythonBridge setClassHandler:self name:@"ServerHandlerProtocolDelegate"];
    if ([_handler respondsToSelector:@selector(defaultServerList)]) {
        _serversList = [_handler defaultServerList];
    }
    if ([_handler respondsToSelector:@selector(customServerName)]) {
        _customServerName = [_handler customServerName];
    }
    NSNumber *customServerActive = @(NO);
    if ([_handler respondsToSelector:@selector(customServerActive)]) {
        customServerActive = [_handler customServerActive];
    }
    _segmentedControl.selectedSegmentIndex = (customServerActive.boolValue) ? 1 : 0;
    [self.tableView registerNib:[UINib nibWithNibName:@"LabelCellSmall" bundle:nil] forCellReuseIdentifier:@"LabelCellSmall"];
    [_segmentedControl setTitle:L(@"Default servers") forSegmentAtIndex:0];
    [_segmentedControl setTitle:L(@"Custom") forSegmentAtIndex:1];
    [_rightButton setTitle:L(@"Add") forState:UIControlStateNormal];
    [self updateRightButtonVisibility];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableViewDataSource
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSCAssert(indexPath.row < _serversList.count, @"indexPath: %@ out of bounds: %@", indexPath, _serversList);
    NSString *serverName = (_segmentedControl.selectedSegmentIndex == 0) ? _serversList[indexPath.row] : _customServerName;
    LabelCell *cell = [tableView dequeueReusableCellWithIdentifier:@"LabelCellSmall"];
    [cell setTitle:serverName];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return (_segmentedControl.selectedSegmentIndex == 0) ? _serversList.count : 1;
}

#pragma mark - UITableViewDelegate
- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    return (_segmentedControl.selectedSegmentIndex == 0) ? nil : ((_customServerName.length) ? indexPath : nil);
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (_segmentedControl.selectedSegmentIndex == 1 && indexPath.row == 0) {
        [self callChangeServerName];
    }
}

#pragma mark - Value Changed
- (IBAction)valueChanged:(UISegmentedControl *)sender {
    if ([_handler respondsToSelector:@selector(setCustomServerActive:)]) {
        [_handler setCustomServerActive:(sender.selectedSegmentIndex == 0) ? @(NO) : @(YES)];
    }
    [self updateRightButtonVisibility];
    [self.tableView reloadData];
}

- (void)updateRightButtonVisibility {
    _rightButton.hidden = (!_segmentedControl.selectedSegmentIndex || _customServerName.length) ? YES : NO;
}

#pragma mark - Observers
- (IBAction)rightButtonTapped:(id)sender {
    [self callChangeServerName];
}

- (void)callChangeServerName {
    dispatch_python(^{
        if ([_handler respondsToSelector:@selector(changeServerNameTapped:)]) {
            [_handler changeServerNameTapped:_customServerName.length ? _customServerName : @""];
        }
    });
}

#pragma mark - ServerHandlerProtocolDelegate
- (void)customServerNameUpdated:(NSString *)customServerName {
    dispatch_async(dispatch_get_main_queue(), ^{
        _customServerName = customServerName;
        [self reloadData];
    });
}

#pragma mark - Private Methods
- (void)reloadData {
    [self updateRightButtonVisibility];
    [self.tableView reloadData];
}

@end
