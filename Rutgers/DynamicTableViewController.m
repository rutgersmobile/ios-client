//
//  DynamicTableViewController.m
//  Rutgers
//
//  Created by Kyle Bailey on 8/22/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

#import "DynamicTableViewController.h"
#import "DynamicDataSource.h"
#import "TableViewController_Private.h"

@interface DynamicTableViewController ()
@property NSDictionary *channel;
@end

@implementation DynamicTableViewController
+(instancetype)newWithChannel:(NSDictionary *)channel{
    return [[self alloc] initWithChannel:channel];
}

-(instancetype)initWithChannel:(NSDictionary *)channel{
    BOOL grouped = [channel[@"grouped"] boolValue];
    self = [super initWithStyle:grouped ? UITableViewStyleGrouped : UITableViewStylePlain];
    if (self) {
        self.channel = channel;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.tableView.decelerationRate = UIScrollViewDecelerationRateFast;
    self.dataSource = [[DynamicDataSource alloc] initWithChannel:self.channel];
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    //Get the item tapped on
    id item = [self.dataSource itemAtIndexPath:indexPath];
    
    //Either the item is the channel or has a channel
    NSDictionary *channel = item[@"channel"];
    if (!channel) channel = item;
    
    //Get view controller to display
    UIViewController *vc = [[RUChannelManager sharedInstance] viewControllerForChannel:channel];
    
    //Sometimes the title is on the item and not its channel
    if (![channel channelTitle] && [item channelTitle]) vc.title = [item channelTitle];
    
    [self.navigationController pushViewController:vc animated:YES];
}


@end
