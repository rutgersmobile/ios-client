//
//  RUReaderController.m
//  Rutgers
//
//  Created by Kyle Bailey on 4/16/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

#import "RUReaderViewController.h"
#import "RUReaderItem.h"
#import "RUReaderDataSource.h"

@interface RUReaderViewController ()
@property (nonatomic) NSDictionary *channel;
@end

@implementation RUReaderViewController
+(instancetype)newWithChannel:(NSDictionary *)channel{
    return [[self alloc] initWithChannel:channel];
}

-(instancetype)initWithChannel:(NSDictionary *)channel{
    self = [self initWithStyle:UITableViewStylePlain];
    if (self) {
        self.channel = channel;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.tableView.rowHeight = 135;
    self.tableView.estimatedRowHeight = self.tableView.rowHeight;
    self.dataSource = [[RUReaderDataSource alloc] initWithUrl:[self.channel channelURL]];
}

-(void)dataSource:(DataSource *)dataSource didLoadContentWithError:(NSError *)error{
    if (!self.refreshControl && !error) {
        //Upon successful load, add the refresh control to the view
        self.refreshControl = [[UIRefreshControl alloc] init];
        [self.refreshControl addTarget:self.dataSource action:@selector(setNeedsLoadContent) forControlEvents:UIControlEventValueChanged];
    }
    [self.refreshControl endRefreshing];
}

-(BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath{
    //Super wont allow highlighting/selection if the placeholder is showing, if super says no go along with it
    BOOL should = [super tableView:tableView shouldHighlightRowAtIndexPath:indexPath];
    if (!should) return NO;
    
    //Allow only if there is a url to go to
    RUReaderItem *row = [self.dataSource itemAtIndexPath:indexPath];
    
    return row.url ? YES : NO;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    RUReaderItem *row = [self.dataSource itemAtIndexPath:indexPath];
    if (!row.url) return;
    
    //Push a new view controller with a web view
    [self.navigationController pushViewController:[[RUChannelManager sharedInstance] viewControllerForChannel:@{@"title" : row.title, @"view" : @"www", @"url" : row.url}] animated:YES];
}
@end
