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
@property (nonatomic) NSDictionary *channel;
@property AFHTTPSessionManager *sessionManager;
@end

@implementation Reader
+(instancetype)componentForChannel:(NSDictionary *)channel{
    return [[Reader alloc] initWithChannel:channel];
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
    self.tableView.rowHeight = 80.0;
    [self.tableView registerClass:[RUReaderTableViewCell class] forCellReuseIdentifier:@"RUReaderTableViewCell"];

    self.sessionManager = [[AFHTTPSessionManager alloc] init];
    self.sessionManager.responseSerializer = [AFImageResponseSerializer serializer];
    
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl beginRefreshing];
    [self fetchDataForChannel];
    [self.refreshControl addTarget:self action:@selector(fetchDataForChannel) forControlEvents:UIControlEventValueChanged];
    
}

-(void)fetchDataForChannel{
    [[RUNetworkManager xmlSessionManager] GET:self.channel[@"url"] parameters:0 success:^(NSURLSessionDataTask *task, id responseObject) {
        if ([responseObject isKindOfClass:[NSDictionary class]]) {
            [self.refreshControl endRefreshing];
            [self parseResponse:[responseObject[@"channel"] firstObject][@"item"]];
        } else {
            [self fetchDataForChannel];
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        [self fetchDataForChannel];
    }];
}

-(void)parseResponse:(id)responseObject{
    [self.tableView beginUpdates];
    if (self.numberOfSections) {
        [self removeAllSections];
    }
    EZTableViewSection *section = [[EZTableViewSection alloc] init];
    for (NSDictionary *item in responseObject) {
        //[[[self class] allKeysSet] addObjectsFromArray:[item allKeys]];
        RUReaderTableViewRow *row = [[RUReaderTableViewRow alloc] initWithItem:item];
        NSString *link = [item[@"link"] firstObject];
        if (link) {
            row.didSelectRowBlock = ^{
                TOWebViewController *webBrowser = [[TOWebViewController alloc] initWithURLString:link];
                webBrowser.title = [item[@"title"] firstObject];
                [self.navigationController pushViewController:webBrowser animated:YES];
            };
        }
        [section addRow:row];
    }
    [self addSection:section];

    [self.tableView endUpdates];
}
-(void)setupCell:(ALTableViewAbstractCell *)cell inTableView:(UITableView *)tableView forRowAtIndexPath:(NSIndexPath *)indexPath{
    RUReaderTableViewRow *row = (RUReaderTableViewRow *)[self rowInTableView:tableView forIndexPath:indexPath];
    RUReaderTableViewCell *readerCell = (RUReaderTableViewCell *)cell;
    [row setupCell:readerCell];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    RUReaderTableViewRow *row = (RUReaderTableViewRow *)[self rowInTableView:tableView forIndexPath:indexPath];
    if (row.date) {
        return IMAGE_HEIGHT + IMAGE_BOTTOM_PADDING;
    } else {
        return IMAGE_HEIGHT;
    }
}
 /*
-(CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath{

    return 200*320/CGRectGetWidth(tableView.bounds);
}*/
@end
