//
//  RUDiningHallViewController.m
//  Rutgers
//
//  Created by Kyle Bailey on 5/1/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

#import "RUDiningHallViewController.h"
#import "RUMealViewController.h"
#import "EZDataSource.h"
#import "EZTableViewRightDetailRow.h"


@interface RUDiningHallViewController ()
@end

@implementation RUDiningHallViewController
-(id)initWithDiningHall:(NSDictionary *)diningHall{
    self = [super initWithStyle:UITableViewStyleGrouped];
    if (self) {
        self.diningHall = diningHall;
        self.title = diningHall[@"location_name"];
        [self makeSections];
    }
    return self;
}

-(void)makeSections{
    EZDataSourceSection *section = [[EZDataSourceSection alloc] initWithSectionTitle:@"Meals"];
    for (NSDictionary *meal in self.diningHall[@"meals"]) {
        EZTableViewRightDetailRow *row = [[EZTableViewRightDetailRow alloc] initWithText:meal[@"meal_name"]];
        row.active = [meal[@"genres"] count];
        row.didSelectRowBlock = ^{
            [self.navigationController pushViewController:[[RUMealViewController alloc] initWithMeal:meal] animated:YES];
        };
        [section addItem:row];
    }
    [self.dataSource addSection:section];
}

@end
