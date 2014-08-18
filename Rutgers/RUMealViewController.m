//
//  RUMealViewController.m
//  Rutgers
//
//  Created by Kyle Bailey on 5/1/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

#import "RUMealViewController.h"
#import "RUNutritionLabelViewController.h"
#import "EZDataSource.h"
#import "EZTableViewRightDetailRow.h"

@interface RUMealViewController ()
@end

@implementation RUMealViewController

-(id)initWithMeal:(NSDictionary *)meal{
    self = [super initWithStyle:UITableViewStylePlain];
    if (self) {
        self.meal = meal;
        self.title = meal[@"meal_name"];
        [self makeSections];
    }
    return self;
}

-(void)viewDidLoad{
    [super viewDidLoad];
}

-(void)makeSections{
    for (NSDictionary *genre in self.meal[@"genres"]) {
        EZDataSourceSection *section = [[EZDataSourceSection alloc] initWithSectionTitle:genre[@"genre_name"]];
        for (NSString *item in genre[@"items"]) {
            EZTableViewRightDetailRow *row = [[EZTableViewRightDetailRow alloc] initWithText:item];
            row.shouldHighlight = NO;
            [section addItem:row];
        }
        [self.dataSource addDataSource:section];
    }
}
@end
