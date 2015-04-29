//
//  RUOptionsViewController.m
//  Rutgers
//
//  Created by Kyle Bailey on 8/25/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

#import "RUOptionsViewController.h"
#import "OptionsDataSource.h"
#import "RULegalViewController.h"
#import "AlertDataSource.h"
#import "TableViewController_Private.h"
#import "RUAppDelegate.h"

@interface RUOptionsViewController ()
@property NSDictionary *channel;
@end

@implementation RUOptionsViewController

+(id)newWithOptions:(NSDictionary *)channel{
    return [[self alloc] initWithStyle:UITableViewStyleGrouped];
}

- (void)viewDidLoad
{
    [super viewDidLoad];    
    self.dataSource = [[OptionsDataSource alloc] init];
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 3) {
        // Open the legal view controller
        [self.navigationController pushViewController:[[RULegalViewController alloc] initWithStyle:UITableViewStylePlain] animated:YES];
    } else {
        // Trigger the alert action
        DataSource *dataSource = [(ComposedDataSource *)self.dataSource dataSourceAtIndex:indexPath.section];
        if ([dataSource isKindOfClass:[AlertDataSource class]]) {
            AlertDataSource *alertDataSource = (AlertDataSource *)dataSource;
            [alertDataSource showAlertInView:tableView];
        }
    }
}

- (BOOL)canBecomeFirstResponder
{
    return YES;
}

-(void)motionBegan:(UIEventSubtype)motion withEvent:(UIEvent *)event{
    if (motion == UIEventSubtypeMotionShake)
    {
        [self deviceShaken];
    }
}


-(void)deviceShaken{
    //Aarons special cache clearing shake
    [[[UIAlertView alloc] initWithTitle:@"Cache Cleared" message:@"Your cache has been cleared." delegate:nil cancelButtonTitle:nil otherButtonTitles:@"Ok", nil] show];
    [((RUAppDelegate *)[UIApplication sharedApplication].delegate) clearCache];
}

@end
