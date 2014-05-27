//
//  RUDiningHallViewController.m
//  Rutgers
//
//  Created by Kyle Bailey on 5/1/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

#import "RUDiningHallViewController.h"
#import "RUMealViewController.h"

@interface RUDiningHallViewController ()
@property (nonatomic) NSDictionary *diningHall;
@end

@implementation RUDiningHallViewController
-(id)initWithDiningHall:(NSDictionary *)diningHall{
    self = [super initWithStyle:UITableViewStyleGrouped];
    if (self) {
        self.diningHall = diningHall;
        self.title = diningHall[@"location_name"];
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
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.diningHall[@"meals"] count];
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    return @"Meals";
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    NSDictionary *mealForCell = self.diningHall[@"meals"][indexPath.row];
    // Configure the cell...
    cell.textLabel.text = mealForCell[@"meal_name"];
    if ([mealForCell[@"genres"] count])  {
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.userInteractionEnabled = YES;
        cell.textLabel.textColor = [UIColor blackColor];
    } else {
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.userInteractionEnabled = NO;
        cell.textLabel.textColor = [UIColor lightGrayColor];
    }
    return cell;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NSDictionary *meal = self.self.diningHall[@"meals"][indexPath.row];
    RUMealViewController *mealVC = [[RUMealViewController alloc] initWithMeal:meal];
    [self.navigationController pushViewController:mealVC animated:YES];

}

@end
