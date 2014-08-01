//
//  RUSOCOptionsViewController.m
//  Rutgers
//
//  Created by Kyle Bailey on 7/10/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

#import "RUSOCOptionsViewController.h"
#import "ALTableViewTextCell.h"
#import "RUSOCDataLoadingManager.h"

@interface RUSOCOptionsViewController () <UITableViewDelegate, UIActionSheetDelegate>
@property id<RUSOCOptionsDelegate> delegate;
@property RUSOCDataLoadingManager *SOCData;
@property NSArray *actionSheets;
@end

@implementation RUSOCOptionsViewController

- (instancetype)initWithDelegate:(id<RUSOCOptionsDelegate>)delegate
{
    self = [super initWithStyle:UITableViewStyleGrouped];
    if (self) {
        self.title = @"Options";
        self.SOCData = [RUSOCDataLoadingManager sharedInstance];
        self.delegate = delegate;
        self.actionSheets = @[[self actionSheetWithData:self.SOCData.semesters],[self actionSheetWithData:self.SOCData.campuses],[self actionSheetWithData:self.SOCData.levels]];
    }
    return self;
}

-(void)viewDidLoad{
    [super viewDidLoad];
    [self.tableView registerClass:[ALTableViewTextCell class] forCellReuseIdentifier:NSStringFromClass([ALTableViewTextCell class])];
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 3;
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    return @[@"Semester",@"Campus",@"Level"][section];
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 1;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    ALTableViewTextCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([ALTableViewTextCell class])];
    NSDictionary *item;
    switch (indexPath.section) {
        case 0:
            item = self.SOCData.semester;
            break;
        case 1:
            item = self.SOCData.campus;
            break;
        case 2:
            item = self.SOCData.level;
            break;
        default:
            break;
    }
    cell.textLabel.text = item[@"title"];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [self presentActionSheet:self.actionSheets[indexPath.section]];
}

-(UIActionSheet *)actionSheetWithData:(NSArray *)data{
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:nil];
    for (NSDictionary *item in data) {
        [actionSheet addButtonWithTitle:item[@"title"]];
    }
    return actionSheet;
}

-(void)presentActionSheet:(UIActionSheet *)actionSheet{
    [actionSheet showInView:self.view];
}

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    NSInteger indexOfSheet = [self.actionSheets indexOfObject:actionSheet];
    switch (indexOfSheet) {
        case 0:
            self.SOCData.semester = self.SOCData.semesters[buttonIndex];
            break;
        case 1:
            self.SOCData.campus = self.SOCData.campuses[buttonIndex];
            break;
        case 2:
            self.SOCData.level = self.SOCData.levels[buttonIndex];
            break;
        default:
            break;
    }
    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:indexOfSheet] withRowAnimation:UITableViewRowAnimationAutomatic];
    [self.delegate optionsViewControllerDidChangeOptions:self];
}

@end
