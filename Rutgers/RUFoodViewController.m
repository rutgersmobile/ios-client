//
//  RUFoodViewController.m
//  Rutgers
//
//  Created by Kyle Bailey on 5/1/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

#import "RUFoodViewController.h"
#import "RUDiningHallViewController.h"
#import "RUFoodDataSource.h"
#import "DataTuple.h"
#import "NSDictionary+DiningHall.h"
#import "MSWeakTimer.h"
#import "RUChannelManager.h"

@interface RUFoodViewController ()
@property MSWeakTimer *timer;
@end

@implementation RUFoodViewController
+(NSString *)channelHandle{
    return @"food";
}
+(void)load{
    [[RUChannelManager sharedInstance] registerClass:[self class]];
}

+(instancetype)channelWithConfiguration:(NSDictionary *)channel{
    return [[self alloc] initWithStyle:UITableViewStyleGrouped];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.tableView.decelerationRate = UIScrollViewDecelerationRateFast;
    self.dataSource = [[RUFoodDataSource alloc] init];
    self.timer = [MSWeakTimer scheduledTimerWithTimeInterval:2*60*60 target:self selector:@selector(timerDidFire) userInfo:nil repeats:YES dispatchQueue:dispatch_get_main_queue()];
}

-(void)timerDidFire{
    [self.dataSource setNeedsLoadContent];
    [self.navigationController popToRootViewControllerAnimated:YES];
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    DataTuple *item = [self.dataSource itemAtIndexPath:indexPath];
    NSDictionary *object = item.object;
    if (object[@"view"]) {
        [self.navigationController pushViewController:[[RUChannelManager sharedInstance] viewControllerForChannel:object] animated:YES];
    } else if ([object isDiningHallOpen]){
        [self.navigationController pushViewController:[[RUDiningHallViewController alloc] initWithDiningHall:object] animated:YES];
    }
}

+(NSArray *)viewControllersWithPathComponents:(NSArray *)pathComponents destinationTitle:(NSString *)title{
    RUDiningHallViewController *viewController = [[RUDiningHallViewController alloc] initWithSerializedDiningHall:pathComponents.firstObject title:title];
    return @[viewController];
}

-(BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath{
    if (![super tableView:tableView shouldHighlightRowAtIndexPath:indexPath]) return NO;
    DataTuple *item = [self.dataSource itemAtIndexPath:indexPath];
    NSDictionary *object = item.object;
    if (!object[@"view"]) {
        return [object isDiningHallOpen];
    }
    return YES;
}
@end
