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

@interface RUFoodViewController ()
@property (nonatomic) RUFoodData *foodData;
@property (nonatomic) NSArray *diningHalls;
@end

@implementation RUFoodViewController
+(instancetype)component{
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
    
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"Cell"];

    [self.foodData getFoodWithCompletion:^(NSArray *response) {
        [self.tableView beginUpdates];
        self.diningHalls = response;
        [self.tableView reloadSections:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, 3)] withRowAnimation:UITableViewRowAnimationAutomatic];
        [self.tableView endUpdates];
    }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (self.diningHalls) {
        switch (section) {
            case 0:
                return self.diningHalls.count;
                break;
            default:
                return 1;
                break;
        }
    }
    return 0;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    switch (indexPath.section) {
        case 0:
        {
            NSDictionary *diningHall = self.diningHalls[indexPath.row];
            cell.textLabel.text = diningHall[@"location_name"];
        }
            break;
        case 1:
            cell.textLabel.text = @"Gateway Cafe";
            break;
        case 2:
            cell.textLabel.text = @"Stonsby Commons & Eatery";
            break;
        default:
            break;
    }
    
    return cell;
}
-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    switch (section) {
        case 0:
            return @"New Brunswick";
            break;
        case 1:
            return @"Camden";
            break;
        case 2:
            return @"Newark";
            break;
        default:
            return nil;
            break;
    }
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    switch (indexPath.section) {
        case 0:
        {
            NSDictionary *diningHall = self.diningHalls[indexPath.row];
            RUDiningHallViewController *diningVC = [[RUDiningHallViewController alloc] initWithDiningHall:diningHall];
            [self.navigationController pushViewController:diningVC animated:YES];
        }
            break;
        case 1:
            break;
        case 2:
            break;
        default:
            break;
    }
}

@end
