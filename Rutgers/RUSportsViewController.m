//
//  RUSportsViewController.m
//  Rutgers
//
//  Created by Kyle Bailey on 6/9/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

#import "RUSportsViewController.h"
#import "RUSportsData.h"
#import "RUSportsRosterViewController.h"
#import "TupleDataSource.h"
#import "DataTuple.h"

@interface RUSportsViewController ()
@property RUSportsData *sportsData;
@end

@implementation RUSportsViewController
+(instancetype)channelWithConfiguration:(NSDictionary *)channel{
    return [[RUSportsViewController alloc] initWithStyle:UITableViewStyleGrouped];
}

-(void)viewDidLoad{
    [super viewDidLoad];
    [self makeSections];
}

-(void)makeSections{
    self.sportsData = [[RUSportsData alloc] init];
    
    NSDictionary *allSports = [RUSportsData allSports];
    
    NSMutableArray *items = [NSMutableArray array];
    NSArray *sports = [[allSports allKeys] sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)];
    for (NSString *sport in sports) {
        DataTuple *item = [[DataTuple alloc] initWithTitle:sport object:allSports[sport]];
        [items addObject:item];
    }
    self.dataSource = [[TupleDataSource alloc] initWithItems:items];
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    DataTuple *item = [self.dataSource itemAtIndexPath:indexPath];
    RUSportsRosterViewController *rosterVC = [[RUSportsRosterViewController alloc] initWithSportID:item.object];
    rosterVC.title = item.title;
    [self.navigationController pushViewController:rosterVC animated:YES];
}

@end
