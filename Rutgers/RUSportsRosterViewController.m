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
#import "TableViewController_Private.h"

@interface RUSportsRosterViewController ()
@property NSString *sportID;
@end

@implementation RUSportsRosterViewController

-(instancetype)initWithSportID:(NSString *)sportID{
    self = [super initWithStyle:UITableViewStyleGrouped];
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

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    id item = [self.dataSource itemAtIndexPath:indexPath];
    if ([item isKindOfClass:[RUSportsPlayer class]]) {
        [((TeamDataSource *)self.dataSource) toggleExpansionForPlayer:item];
    }
}

@end
