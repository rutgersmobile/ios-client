//
//  RUMealViewController.m
//  Rutgers
//
//  Created by Kyle Bailey on 5/1/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

#import "RUMealViewController.h"
#import "RUNutritionLabelViewController.h"

@interface RUMealViewController ()
@property (nonatomic) NSDictionary *meal;
@end

@implementation RUMealViewController
-(id)initWithMeal:(NSDictionary *)meal{
    self = [super initWithStyle:UITableViewStylePlain];
    if (self) {
        self.meal = meal;
        self.title = meal[@"meal_name"];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"Cell"];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source
-(id)itemForIndexPath:(NSIndexPath *)indexPath{
    return self.meal[@"genres"][indexPath.section][@"items"][indexPath.row];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [self.meal[@"genres"] count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.meal[@"genres"][section][@"items"] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    NSDictionary *itemForCell = [self itemForIndexPath:indexPath];
    if ([self showInfoForItem:itemForCell]) {
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    } else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    cell.textLabel.text = [itemForCell[@"name"] capitalizedString];
    return cell;
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    return [self.meal[@"genres"][section][@"genre_name"] capitalizedString];
}
-(BOOL)showInfoForItem:(NSDictionary *)item{
    return ([item count] > 1);
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if ([self showInfoForItem:[self itemForIndexPath:indexPath]]) {
        RUNutritionLabelViewController *nutritionVC = [[RUNutritionLabelViewController alloc] initWithFoodItem:[self itemForIndexPath:indexPath]];
        [self.navigationController pushViewController:nutritionVC animated:YES];
    } else {
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
    }
}

@end
