//
//  DynamicTableViewController.m
//  Rutgers
//
//  Created by Kyle Bailey on 8/22/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

#import "DynamicTableViewController.h"
#import "DynamicDataSource.h"
#import "RUChannelManager.h"
#import "NSDictionary+Channel.h"
#import "NSURL+RUAdditions.h"

/*
    This is the generic view used to represent all the inner subviews of the View Contr. from the slideView
    channel is a dictionary holding information about the view to be displayed and the sub views within that view.
    It also contains information about the url used to represent the view in a heirachy of all the views and the title used to display the item within the cell
 */


@interface DynamicTableViewController ()
@property NSDictionary *channel;
@end

@implementation DynamicTableViewController


+(NSString *)channelHandle
{
    return @"dtable";
}

// called by objc run time when classes start up 
+(void)load
{
    [[RUChannelManager sharedInstance] registerClass:[self class]];
}

/*
    Sets up specfic features of the dtable
 */
+(instancetype)channelWithConfiguration:(NSDictionary *)channel
{
    return [[self alloc] initWithChannel:channel];
}

/*
    Determine whether the view has to be grouped together or whether is can be displayed as a single group
    and set up the data source of the table view..
 */
-(instancetype)initWithChannel:(NSDictionary *)channel
{
    //BOOL grouped = [channel[@"grouped"] boolValue];
    //self = [super initWithStyle:grouped ? UITableViewStyleGrouped : UITableViewStylePlain];
    self = [super initWithStyle: UITableViewStyleGrouped];
    
    if (self)
    {
        self.channel = channel;
    }
    return self;
}


/*
    Goes over the view controllers and collects the channel names into an array
    and returns them as a url
 */
+(NSURL *)buildDynamicSharingURL:(UINavigationController*)navigationController channel:(NSDictionary*)channel {
    
    NSMutableArray *pathComponents = [NSMutableArray array];
    
    for (id viewController in navigationController.viewControllers) {
        if ([viewController respondsToSelector:@selector(channel)]) {
            NSDictionary *channel = [viewController channel];
            NSString *handle = [channel channelHandle];
            if (handle) {
                [pathComponents addObject:handle];
            } else {
                [pathComponents addObject:[[channel channelTitle] rutgersStringEscape]];
            }
        }
    }
    return [NSURL rutgersUrlWithPathComponents: pathComponents];
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    self.tableView.decelerationRate = UIScrollViewDecelerationRateFast;
    self.dataSource = [[DynamicDataSource alloc] initWithChannel:self.channel];
}

/*
    The structure is recursive , once an item on this table view is clicked , a new view controller is created , which again , 
    has its own table view and item . 
    Based on the item clicked , and its properties , the next view controller to be displayed is set up.
    Then we move to the next view controller
 */
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    //Get the item tapped on
    id item = [self.dataSource itemAtIndexPath:indexPath];
    
    //Either the item is the channel or has a channel
    // it might be dictionary containing a children key and the an array of channels
    NSDictionary *channel = item[@"channel"];
    if (!channel) channel = item;
    
    //Get view controller to display
    UIViewController *vc = [[RUChannelManager sharedInstance] viewControllerForChannel:channel];
  
    
    //Sometimes the title is on the item and not its channel
    if (![channel channelTitle] && [item channelTitle]) vc.title = [item channelTitle];
   
  
     // Now move to the next view controller
    [self.navigationController pushViewController:vc animated:YES];
}


@end
