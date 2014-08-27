//
//  DynamicTableViewController.m
//  Rutgers
//
//  Created by Kyle Bailey on 8/22/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

#import "DynamicTableViewController.h"
#import "DynamicDataSource.h"

@interface DynamicTableViewController ()
@property NSDictionary *channel;
@end

@implementation DynamicTableViewController
+(id)channelWithConfiguration:(NSDictionary *)channel{
    return [[self alloc] initWithChannel:channel];
}

-(id)initWithChannel:(NSDictionary *)channel{
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
    // Do any additional setup after loading the view.
    
    self.dataSource = [[DynamicDataSource alloc] initWithChannel:self.channel];
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    id item = [self.dataSource itemAtIndexPath:indexPath];
    
    NSDictionary *channel = item[@"channel"];
    if (!channel) channel = item;
    
    UIViewController *vc = [[RUChannelManager sharedInstance] viewControllerForChannel:channel];
    if (![channel channelTitle] && [item channelTitle]) vc.title = [item channelTitle];
    
    [self.navigationController pushViewController:vc animated:YES];
}


@end
