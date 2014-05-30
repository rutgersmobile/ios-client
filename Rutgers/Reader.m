//
//  RUReaderController.m
//  Rutgers
//
//  Created by Kyle Bailey on 4/16/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

#import "Reader.h"
#import <AFNetworking.h>
#import "RUReaderTableViewCell.h"
#import <TOWebViewController.h>
#import "RUNetworkManager.h"
#import "RUChannelManager.h"
#import "EZTableViewSection.h"
#import "RUReaderTableViewRow.h"

@interface Reader ()
@property (nonatomic) NSArray *items;
@property (nonatomic) NSDictionary *channel;
@end
@interface Reader ()
@property EZTableViewSection *section;
@end
@implementation Reader
+(instancetype)componentForChannel:(NSDictionary *)channel{
    return [[Reader alloc] initWithChannel:channel];
}

-(id)initWithStyle:(UITableViewStyle)style{
    self = [super initWithStyle:style];
    if (self) {
        self.tableView.rowHeight = 80.0;
        self.section = [[EZTableViewSection alloc] init];
        [self addSection:self.section];
    }
    return self;
}

-(id)initWithChannel:(NSDictionary *)channel{
    self = [self initWithStyle:UITableViewStylePlain];
    if (self) {
        self.channel = channel;
        self.title = [channel titleForChannel];
        [self fetchDataForChannel];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.tableView registerClass:[RUReaderTableViewCell class] forCellReuseIdentifier:@"RUReaderTableViewCell"];

    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl beginRefreshing];
    [self.refreshControl addTarget:self action:@selector(fetchDataForChannel) forControlEvents:UIControlEventValueChanged];
    
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.navigationController setToolbarHidden:YES animated:NO];
}

-(void)fetchDataForChannel{
    [[RUNetworkManager xmlSessionManager] GET:self.channel[@"url"] parameters:0 success:^(NSURLSessionDataTask *task, id responseObject) {
        if ([responseObject isKindOfClass:[NSDictionary class]]) {
            NSDictionary *channel = [responseObject[@"channel"] firstObject];
            self.items = channel[@"item"];
            [self makeSection];
            [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationFade];
            [self.refreshControl endRefreshing];
        } else {
            [self fetchDataForChannel];
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        [self fetchDataForChannel];
    }];
}

-(void)makeSection{
    [self.section removeAllRows];
    for (NSDictionary *item in self.items) {
        RUReaderTableViewRow *row = [[RUReaderTableViewRow alloc] initWithItem:item];
        NSString *link = [item[@"link"] firstObject];
        if (link) {
            row.didSelectRowBlock = ^{
                TOWebViewController *webBrowser = [[TOWebViewController alloc] initWithURLString:link];
                webBrowser.title = [item[@"title"] firstObject];
                [self.navigationController pushViewController:webBrowser animated:YES];
            };
        }
        [self.section addRow:row];
    }
}
-(CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 200*320/CGRectGetWidth(tableView.bounds);
}
@end
