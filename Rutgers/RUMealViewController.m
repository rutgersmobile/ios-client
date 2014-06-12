//
//  RUMealViewController.m
//  Rutgers
//
//  Created by Kyle Bailey on 5/1/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

#import "RUMealViewController.h"
#import "RUNutritionLabelViewController.h"
#import "EZTableViewSection.h"
#import "EZTableViewRightDetailRow.h"

@interface RUMealViewController ()
@property (nonatomic) NSDictionary *meal;
@end

@implementation RUMealViewController

-(id)initWithMeal:(NSDictionary *)meal{
    self = [super initWithStyle:UITableViewStylePlain];
    if (self) {
        self.meal = meal;
        self.title = meal[@"meal_name"];
        for (NSDictionary *genre in self.meal[@"genres"]) {
            EZTableViewSection *section = [[EZTableViewSection alloc] initWithSectionTitle:[genre[@"genre_name"] capitalizedString]];
            for (NSDictionary *item in genre[@"items"]) {
                EZTableViewRightDetailRow *row = [[EZTableViewRightDetailRow alloc] initWithText:[item[@"name"] capitalizedString]];
                if ([self shouldShowInfoForItem:item]) {
                    row.didSelectRowBlock = ^{
                        [self.navigationController pushViewController:[[RUNutritionLabelViewController alloc] initWithFoodItem:item] animated:YES];
                    };
                }
                [section addRow:row];
            }
            [self addSection:section];
        }
    }
    return self;
}

-(BOOL)shouldShowInfoForItem:(NSDictionary *)item{
    return ([item count] > 1);
}
@end
