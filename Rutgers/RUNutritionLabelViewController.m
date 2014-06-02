//
//  RUNutritionLabelViewController.m
//  Rutgers
//
//  Created by Kyle Bailey on 5/10/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//


#import "RUNutritionLabelViewController.h"


@interface RUDetailTableViewCell : UITableViewCell

@end

@implementation RUDetailTableViewCell
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    // ignore the style argument, use our own to override
    self = [super initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:reuseIdentifier];
    return self;
}
@end


@interface RUNutritionLabelViewController ()
@property (nonatomic) NSDictionary *foodItem;
@end

@implementation RUNutritionLabelViewController

-(id)initWithFoodItem:(NSDictionary *)foodItem{
    self = [self initWithStyle:UITableViewStyleGrouped];
    if (self) {
        self.foodItem = foodItem;
        self.title = [foodItem[@"name"] capitalizedString];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.tableView registerClass:[RUDetailTableViewCell class] forCellReuseIdentifier:@"Cell"];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    switch (indexPath.section) {
        case 0:
            switch (indexPath.row) {
                case 0:
                    cell.textLabel.text = [self.foodItem[@"calories"] description];
                    cell.detailTextLabel.text = @"Calories";
                    break;
                case 1:
                    cell.textLabel.text = [self.foodItem[@"serving"] capitalizedString];
                    cell.detailTextLabel.text = @"Serving";
                    break;
                default:
                    break;
            }
            break;
        case 1:
            cell.textLabel.text = [self.foodItem[@"ingredients"][indexPath.row] capitalizedString];
            cell.detailTextLabel.text = nil;
            break;
            
        default:
            break;
    }
    return cell;
}
-(BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath{
    return NO;
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if ([self.foodItem[@"ingredients"] count]) {
        return 2;
    }
    return 1;
}
-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    if (section == 1) {
        return @"Ingredients";
    }
    return nil;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch (section) {
        case 0:
            return 2;
            break;
        case 1:
            return [self.foodItem[@"ingredients"] count];
            break;
            
        default:
            return 0;
            break;
    }
}

@end
