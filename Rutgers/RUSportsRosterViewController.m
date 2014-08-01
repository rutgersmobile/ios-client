//
//  RUSportsRosterViewController.m
//  Rutgers
//
//  Created by Kyle Bailey on 6/10/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

#import "RUSportsRosterViewController.h"
#import "RUSportsPlayerCell.h"
#import "TeamDataSource.h"
#import "RUSportsPlayer.h"
#import "RUSportsRosterSectionHeaderView.h"
#import "RUSportsRosterPlayerHeaderCell.h"

@interface RUSportsRosterViewController ()
@property NSString *sportID;
@end

@implementation RUSportsRosterViewController

-(id)initWithSportID:(NSString *)sportID{
    self = [super init];
    if (self) {
        self.sportID = sportID;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.tableView.separatorColor = [UIColor clearColor];
    self.dataSource = [[TeamDataSource alloc] initWithSportID:self.sportID];
}

/*
-(NSInteger)indexOfRosterSection{
    return [self.dataSource indexOfSection:self.rosterSection];
}

-(void)selectPlayerAtIndex:(NSInteger)index{
 
    UIView *playerHeaderView = [[RUSportsRosterPlayerHeaderCell alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.bounds), 118)];
    [self.tableView beginUpdates];
    self.tableView.tableHeaderView = playerHeaderView;
    [self.tableView endUpdates];
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    return nil;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    NSString *title = [super tableView:tableView titleForHeaderInSection:section];
    RUSportsRosterSectionHeaderView *headerView = [tableView dequeueReusableHeaderFooterViewWithIdentifier:NSStringFromClass([RUSportsRosterSectionHeaderView class])];
    headerView.sectionHeaderLabel.text = title;
    return headerView;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 38;
}
*/

@end
