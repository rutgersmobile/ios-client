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
#import "RUAppDelegate.h"
#import "RUChannelManager.h"

@interface RUOptionsViewController ()
@property NSDictionary *channel;
@end

@implementation RUOptionsViewController
/*
    Descript : 
        This is
 */
+(NSString *)channelHandle{
    return @"options";
}
+(void)load
{
    [[RUChannelManager sharedInstance] registerClass:[self class]];
    
    // load the RUEditMenuItemView COntroller
   [RUEditMenuItemsViewController registerClass];
    
}

+(instancetype)channelWithConfiguration:(NSDictionary *)channel{
    return [[self alloc] initWithStyle:UITableViewStyleGrouped];
}

- (void)viewDidLoad
{
    [super viewDidLoad];    
    self.dataSource = [[OptionsDataSource alloc] init];
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    /* NO Longer needed . Options moved to root
    if (indexPath.section == 0)
    {
        [self.navigationController pushViewController:[[RUEditMenuItemsViewController alloc] initWithStyle:UITableViewStyleGrouped] animated:YES];
    }
    else
     */
    
    if (indexPath.section == 3) // after the removal of the edit options , the legal is at index 3 ( from index 4)
    {
        // Open the legal view controller
        [self.navigationController pushViewController:[[RULegalViewController alloc] initWithStyle:UITableViewStylePlain] animated:YES];
    }
    else
    {
        // Trigger the alert action
        DataSource *dataSource = [(ComposedDataSource *)self.dataSource dataSourceAtIndex:indexPath.section];
        if ([dataSource isKindOfClass:[AlertDataSource class]]) {
            AlertDataSource *alertDataSource = (AlertDataSource *)dataSource;
            [alertDataSource showAlertInView:tableView];
        }
    }
}

//Below are methods relating to Aarons special request of shaking your device to clear the cache while on the options screen
-(void)motionBegan:(UIEventSubtype)motion withEvent:(UIEvent *)event{
    if (motion == UIEventSubtypeMotionShake)
    {
        [self deviceShaken];
    }
}

//This needs to be implemented to recieve the above message
- (BOOL)canBecomeFirstResponder
{
    return YES;
}

/**
 *  This function will clear the cache, called when the device is shaken
 */
-(void)deviceShaken{
    //Aarons special cache clearing shake
    [[[UIAlertView alloc] initWithTitle:@"Cache Cleared" message:@"Your cache has been cleared." delegate:nil cancelButtonTitle:nil otherButtonTitles:@"Ok", nil] show];
    [((RUAppDelegate *)[UIApplication sharedApplication].delegate) clearCache];
}

@end
