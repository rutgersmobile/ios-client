//
//  RUReaderController.m
//  Rutgers
//
//  Created by Kyle Bailey on 4/16/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

#import "RUReaderViewController.h"
#import "RUReaderTableViewRow.h"
#import "RUChannelManager.h"
#import "RUReaderDataSource.h"

@interface RUReaderViewController ()
@property (nonatomic) NSDictionary *channel;
@end

@implementation RUReaderViewController
+(instancetype)componentForChannel:(NSDictionary *)channel{
    return [[RUReaderViewController alloc] initWithChannel:channel];
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
    self.tableView.rowHeight = 90.0;
    self.tableView.estimatedRowHeight = 90.0;
    self.dataSource = [[RUReaderDataSource alloc] initWithUrl:self.channel[@"url"]];
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    RUReaderTableViewRow *row = [self.dataSource itemAtIndexPath:indexPath];
    
    [self.navigationController pushViewController:[[RUChannelManager sharedInstance] viewControllerForChannel:@{@"title" : row.title, @"view" : @"www", @"url" : row.url}] animated:YES];
}
@end
