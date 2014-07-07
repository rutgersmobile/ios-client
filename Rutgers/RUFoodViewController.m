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
#import "EZTableViewSection.h"
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
    [self startNetworkLoad];
}

-(void)startNetworkLoad{
    [super startNetworkLoad];
    [self.foodData getFoodWithSuccess:^(NSArray *response) {
        [self networkLoadSucceeded];
        [self parseResponse:response];
    } failure:^{
        [self networkLoadFailed];
    }];
}

-(void)parseResponse:(NSArray *)response{
    [self.tableView beginUpdates];
    
    if (self.sections.count) {
        [self removeAllSections];
    }
    
    EZTableViewSection *newBrunswickDining = [[EZTableViewSection alloc] initWithSectionTitle:@"New Brunswick"];
    for (NSDictionary *diningHall in response) {
        EZTableViewRightDetailRow *row = [[EZTableViewRightDetailRow alloc] initWithText:diningHall[@"location_name"]];
        row.didSelectRowBlock = ^{
            [self.navigationController pushViewController:[[RUDiningHallViewController alloc] initWithDiningHall:diningHall] animated:YES];
        };
        [newBrunswickDining addRow:row];
    }
    [self addSection:newBrunswickDining];
    
    for (NSDictionary *staticDiningHall in self.foodData.staticDiningHalls) {
        EZTableViewSection *section = [[EZTableViewSection alloc] initWithSectionTitle:staticDiningHall[@"header"]];
        EZTableViewRightDetailRow *row = [[EZTableViewRightDetailRow alloc] initWithText:staticDiningHall[@"title"]];
        row.didSelectRowBlock = ^{
            [self.navigationController pushViewController:[[RUChannelManager sharedInstance] viewControllerForChannel:staticDiningHall] animated:YES];
        };
        [section addRow:row];
        [self addSection:section];
    }
    
    [self.tableView endUpdates];
}
@end
