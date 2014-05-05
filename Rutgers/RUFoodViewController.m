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

- (instancetype)initWithDelegate:(id<RUComponentDelegate>)delegate
{
    self = [super initWithStyle:UITableViewStyleGrouped];
    if (self) {
        self.delegate = delegate;
        self.foodData = [RUFoodData sharedInstance];
        self.navigationItem.title = @"Food";
        
        // Custom initialization
        self.delegate = delegate;
        if ([self.delegate respondsToSelector:@selector(onMenuButtonTapped)]) {
            // delegate expects menu button notification, so let's create and add a menu button
            UIBarButtonItem * btn = [[UIBarButtonItem alloc] initWithTitle:@"Menu" style:UIBarButtonItemStyleBordered target:self.delegate action:@selector(onMenuButtonTapped)];
            self.navigationItem.leftBarButtonItem = btn;
        }
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
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
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
        default:
            break;
    }
    // Configure the cell...
    
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

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
