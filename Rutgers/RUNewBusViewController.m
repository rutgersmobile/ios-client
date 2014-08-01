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
#import "RULocationManager.h"
#import "RUBusDataLoadingManager.h"
#import "RUPredictionsViewController.h"

@interface RUNewBusViewController ()
@end

@implementation RUNewBusViewController


+(instancetype)componentForChannel:(NSDictionary *)channel{
    return [[self alloc] initWithStyle:UITableViewStylePlain];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Do any additional setup after loading the view.
    self.dataSource = [[RUBusDataSource alloc] init];
    self.searchDataSource = [[BusSearchDataSource alloc] init];
}


-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [[RULocationManager sharedLocationManager] startUpdatingLocation];
    [((RUBusDataSource*)self.dataSource) startUpdates];
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [[RULocationManager sharedLocationManager] stopUpdatingLocation];
    [((RUBusDataSource*)self.dataSource) stopUpdates];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    id item;
    if (tableView == self.tableView) {
        item = [self.dataSource itemAtIndexPath:indexPath];
    } else if (tableView == self.searchDisplayController.searchResultsTableView) {
        item = [self.searchDataSource itemAtIndexPath:indexPath];
    }
    [self.navigationController pushViewController:[[RUPredictionsViewController alloc] initWithItem:item] animated:YES];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
