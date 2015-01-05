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

@interface RUBusViewController ()

@end

@implementation RUBusViewController

+(instancetype)channelWithConfiguration:(NSDictionary *)channel{
    return [[self alloc] initWithStyle:UITableViewStylePlain];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Do any additional setup after loading the view.
    self.dataSource = [[RUBusDataSource alloc] init];
    self.searchDataSource = [[BusSearchDataSource alloc] init];
    self.searchBar.placeholder = @"Search All Routes and Stops";
    
    __weak UISearchBar *weakSearchBar = self.searchBar;
    [[RUBusDataLoadingManager sharedInstance] performWhenAgenciesLoaded:^{
        weakSearchBar.userInteractionEnabled = YES;
    }];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [(RUBusDataSource *)self.dataSource startUpdates];
}

-(void)viewWillDisappear:(BOOL)animated{
    [(RUBusDataSource *)self.dataSource stopUpdates];
    [super viewWillDisappear:animated];
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    id item = [[self dataSourceForTableView:tableView] itemAtIndexPath:indexPath];
    [self.navigationController pushViewController:[[RUPredictionsViewController alloc] initWithItem:item] animated:YES];
}

@end
