//
//  RUNutritionLabelViewController.m
//  Rutgers
//
//  Created by Kyle Bailey on 5/10/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//


#import "RUNutritionLabelViewController.h"
#import "EZTableViewSection.h"
#import "EZTableViewRightDetailRow.h"

@interface RUNutritionLabelViewController ()
@end

@implementation RUNutritionLabelViewController

-(id)initWithFoodItem:(NSDictionary *)foodItem{
    self = [self initWithStyle:UITableViewStyleGrouped];
    if (self) {
        self.foodItem = foodItem;
        self.title = [foodItem[@"name"] capitalizedString];
        [self makeSections];
    }
    return self;
}

-(void)makeSections{
    EZTableViewRightDetailRow *calories = [[EZTableViewRightDetailRow alloc] initWithText:[self.foodItem[@"calories"] stringValue] detailText:@"Calories"];
    EZTableViewRightDetailRow *serving = [[EZTableViewRightDetailRow alloc] initWithText:[self.foodItem[@"serving"] capitalizedString] detailText:@"Serving"];
    
    [self addSection:[[EZTableViewSection alloc] initWithSectionTitle:nil rows:@[calories,serving]]];
    
    if ([self.foodItem[@"ingredients"] count]) {
        EZTableViewSection *ingredients = [[EZTableViewSection alloc] initWithSectionTitle:@"Ingredients"];
        
        for (NSString *ingredient in self.foodItem[@"ingredients"]) {
            EZTableViewRightDetailRow *row = [[EZTableViewRightDetailRow alloc] initWithText:[ingredient capitalizedString] detailText:nil];
            [ingredients addRow:row];
        }
        
        [self addSection:ingredients];
    }
}
@end
