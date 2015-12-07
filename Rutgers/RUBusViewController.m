//
//  RUNewBusViewController.m
//  Rutgers
//
//  Created by Kyle Bailey on 7/22/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

#import "RUBusViewController.h"
#import "RUBusDataSource.h"
#import "BusSearchDataSource.h"
#import "RUBusDataLoadingManager.h"
#import "RUPredictionsViewController.h"
#import "TableViewController_Private.h"
#import "RUChannelManager.h"

@interface RUBusViewController ()

@end

@implementation RUBusViewController
+(NSString *)channelHandle{
    return @"bus";
}
+(void)load{
    [[RUChannelManager sharedInstance] registerClass:[self class]];
}

+(instancetype)channelWithConfiguration:(NSDictionary *)channel{
    return [[self alloc] initWithStyle:UITableViewStylePlain];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // All content is located in the data sources
    self.dataSource = [[RUBusDataSource alloc] init];
    self.searchDataSource = [[BusSearchDataSource alloc] init];
    self.searchBar.placeholder = @"Search All Routes and Stops";
}

//This causes an update timer to start upon the Bus View controller appearing
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [(RUBusDataSource *)self.dataSource startUpdates];
}

//And stops the timer
-(void)viewWillDisappear:(BOOL)animated{
    [(RUBusDataSource *)self.dataSource stopUpdates];
    [super viewWillDisappear:animated];
}

//This is the action send when tapping on a cell, this opens up the predictions screen
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    id item = [[self dataSourceForTableView:tableView] itemAtIndexPath:indexPath];
    [self.navigationController pushViewController:[[RUPredictionsViewController alloc] initWithItem:item] animated:YES];
}

@end
