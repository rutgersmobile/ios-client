//
//  RUOptionsViewController.m
//  Rutgers
//
//  Created by Kyle Bailey on 8/25/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

#import "RUOptionsViewController.h"
#import "OptionsDataSource.h"
#import "RUPreferencesViewController.h"
#import "RULegalViewController.h"

@interface RUOptionsViewController ()
@property NSDictionary *channel;

@end

@implementation RUOptionsViewController

+(id)channelWithConfiguration:(NSDictionary *)channel{
    return [[self alloc] initWithStyle:UITableViewStyleGrouped];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.dataSource = [[OptionsDataSource alloc] init];
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0) {
        [self.navigationController pushViewController:[[RUPreferencesViewController alloc] initWithStyle:UITableViewStyleGrouped] animated:YES];
    } else if (indexPath.section == 1) {
        
    } else if (indexPath.section == 2) {
        [self.navigationController pushViewController:[[RULegalViewController alloc] initWithStyle:UITableViewStyleGrouped] animated:YES];
    }
}

- (BOOL)canBecomeFirstResponder
{
    return YES;
}

- (void)motionEnded:(UIEventSubtype)motion withEvent:(UIEvent *)event
{
    if (motion == UIEventSubtypeMotionShake)
    {
        [self deviceShaken];
    } 
}

-(void)deviceShaken{
    [[[UIAlertView alloc] initWithTitle:@"Cache Cleared" message:@"Your cache has been cleared." delegate:nil cancelButtonTitle:nil otherButtonTitles:@"Ok", nil] show];
    [[NSURLCache sharedURLCache] removeAllCachedResponses];
}
@end
