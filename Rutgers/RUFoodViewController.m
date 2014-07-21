//
//  RUFoodViewController.m
//  Rutgers
//
//  Created by Kyle Bailey on 5/1/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

#import "RUFoodViewController.h"
#import "RUFoodData.h"
#import "RUDiningHallViewController.h"
#import "RUChannelManager.h"
#import "EZDataSource.h"
#import "EZTableViewRightDetailRow.h"


@interface RUFoodViewController ()
@property (nonatomic) RUFoodData *foodData;
@end

@implementation RUFoodViewController
+(instancetype)componentForChannel:(NSDictionary *)channel{
    return [[RUFoodViewController alloc] init];
}
- (instancetype)init{
    self = [super initWithStyle:UITableViewStyleGrouped];
    if (self) {
        self.foodData = [RUFoodData sharedInstance];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setupContentLoadingStateMachine];
}

-(void)loadNetworkData{
    [self.foodData getFoodWithSuccess:^(NSArray *response) {
        [self.contentLoadingStateMachine networkLoadSuccessful];
        [self parseResponse:response];
    } failure:^{
        [self.contentLoadingStateMachine networkLoadFailedWithNoData];
    }];
}

-(void)parseResponse:(NSArray *)response{
    [self.tableView beginUpdates];
    
    [self.dataSource removeAllSections];
    
    EZDataSourceSection *newBrunswickDining = [[EZDataSourceSection alloc] initWithSectionTitle:@"New Brunswick"];
    for (NSDictionary *diningHall in response) {
        EZTableViewRightDetailRow *row = [[EZTableViewRightDetailRow alloc] initWithText:diningHall[@"location_name"]];
        row.didSelectRowBlock = ^{
            [self.navigationController pushViewController:[[RUDiningHallViewController alloc] initWithDiningHall:diningHall] animated:YES];
        };
        [newBrunswickDining addItem:row];
    }
    [self.dataSource addSection:newBrunswickDining];
    
    for (NSDictionary *staticDiningHall in self.foodData.staticDiningHalls) {
        EZDataSourceSection *section = [[EZDataSourceSection alloc] initWithSectionTitle:staticDiningHall[@"header"]];
        EZTableViewRightDetailRow *row = [[EZTableViewRightDetailRow alloc] initWithText:staticDiningHall[@"title"]];
        row.didSelectRowBlock = ^{
            [self.navigationController pushViewController:[[RUChannelManager sharedInstance] viewControllerForChannel:staticDiningHall] animated:YES];
        };
        [section addItem:row];
        [self.dataSource addSection:section];
    }
    
    [self.tableView endUpdates];
}
@end
