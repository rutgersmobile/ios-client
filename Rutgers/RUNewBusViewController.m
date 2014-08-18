//
//  RUNewBusViewController.m
//  Rutgers
//
//  Created by Kyle Bailey on 7/22/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

#import "RUNewBusViewController.h"
#import "RUBusDataSource.h"
#import "BusSearchDataSource.h"
#import "RUBusDataLoadingManager.h"
#import "RUPredictionsViewController.h"

static NSString *const busLastPaneKey = @"busLastPaneKey";

@interface RUNewBusViewController ()

@end

@implementation RUNewBusViewController

+(instancetype)channelWithConfiguration:(NSDictionary *)channel{
    return [[self alloc] initWithStyle:UITableViewStylePlain];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Do any additional setup after loading the view.
    self.dataSource = [[RUBusDataSource alloc] init];
    self.searchDataSource = [[BusSearchDataSource alloc] init];
    
    [self setupToolbar];
}

#pragma mark - Segmented Control

-(void)segmentedControlIndexChanged:(UISegmentedControl *)segmentedControl{
    [[NSUserDefaults standardUserDefaults] setInteger:segmentedControl.selectedSegmentIndex forKey:busLastPaneKey];
}

-(void)setupToolbar{
    [self.segmentedControl addTarget:self action:@selector(segmentedControlIndexChanged:) forControlEvents:UIControlEventValueChanged];

    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults registerDefaults:@{busLastPaneKey: @(1)}];
    
    NSInteger lastPane = [userDefaults integerForKey:busLastPaneKey];
    
    if ([self.dataSource isKindOfClass:[SegmentedDataSource class]]) {
        SegmentedDataSource *dataSource = (SegmentedDataSource *)self.dataSource;
        [dataSource setSelectedDataSourceIndex:lastPane];
        self.segmentedControl.selectedSegmentIndex = lastPane;
    }
}


-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [((RUBusDataSource*)self.dataSource) startUpdates];
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [((RUBusDataSource*)self.dataSource) stopUpdates];
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    id item = [[self dataSourceForTableView:tableView] itemAtIndexPath:indexPath];
    [self.navigationController pushViewController:[[RUPredictionsViewController alloc] initWithItem:item] animated:YES];
}

@end
