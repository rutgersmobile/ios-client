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
#import "TableViewController_Private.h"

@interface RUReaderViewController ()
@property (nonatomic) NSDictionary *channel;
@end

@implementation RUReaderViewController
+(instancetype)channelWithConfiguration:(NSDictionary *)channel{
    return [[self alloc] initWithChannel:channel];
}


-(id)initWithChannel:(NSDictionary *)channel{
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
        self.refreshControl = [[UIRefreshControl alloc] init];
        [self.refreshControl addTarget:self.dataSource action:@selector(setNeedsLoadContent) forControlEvents:UIControlEventValueChanged];
    }
    [self.refreshControl endRefreshing];
}

-(BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath{
    BOOL should = [super tableView:tableView shouldHighlightRowAtIndexPath:indexPath];
    if (!should) return NO;
    
    RUReaderItem *row = [self.dataSource itemAtIndexPath:indexPath];
    
    return row.url ? YES : NO;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    RUReaderItem *row = [self.dataSource itemAtIndexPath:indexPath];
    
    if (!row.url) return;
    
    [self.navigationController pushViewController:[[RUChannelManager sharedInstance] viewControllerForChannel:@{@"title" : row.title, @"view" : @"www", @"url" : row.url}] animated:YES];
}
@end
