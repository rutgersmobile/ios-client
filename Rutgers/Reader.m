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
    self.tableView.estimatedRowHeight = 80.0;

    self.sessionManager = [[AFHTTPSessionManager alloc] init];
    self.sessionManager.responseSerializer = [AFImageResponseSerializer serializer];
    
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(fetchDataForChannel) forControlEvents:UIControlEventValueChanged];
    [self.refreshControl beginRefreshing];
    [self fetchDataForChannel];
    
}

-(void)fetchDataForChannel{
    [self getURL:self.channel[@"url"]];
}

-(void)getURL:(NSString *)url{
    [[RUNetworkManager xmlSessionManager] GET:url parameters:0 success:^(NSURLSessionDataTask *task, id responseObject) {
        if ([responseObject isKindOfClass:[NSDictionary class]]) {
            NSDictionary *channel = [responseObject[@"channel"] firstObject];
            if (channel[@"item"]) {
                [self parseResponse:channel[@"item"]];
            } /*else if (channel[@"link"]) {
                [self getURL:[channel[@"link"] firstObject]];
            }*/
        } else {
            [self fetchDataForChannel];
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        [self fetchDataForChannel];
    }];
}

-(void)parseResponse:(id)responseObject{
    [self.tableView beginUpdates];
   
    if ([self numberOfSectionsInTableView:self.tableView]) {
        [self.tableView deleteSections:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, self.sections.count)] withRowAnimation:UITableViewRowAnimationFade];
        [self removeAllSections];
    }
    
    EZTableViewSection *section = [[EZTableViewSection alloc] init];
    for (NSDictionary *item in responseObject) {
        //[[[self class] allKeysSet] addObjectsFromArray:[item allKeys]];
        RUReaderTableViewRow *row = [[RUReaderTableViewRow alloc] initWithItem:item];
        NSString *link = [item[@"link"] firstObject];
        if (link) {
            row.didSelectRowBlock = ^{
                [self.navigationController pushViewController:[[RUChannelManager sharedInstance] viewControllerForChannel:@{@"title" : [item[@"title"] firstObject], @"view" : @"www", @"url" : link}] animated:YES];
            };
        }
        [section addRow:row];
    }
    [self addSection:section];
    [self.tableView insertSections:[NSIndexSet indexSetWithIndex:self.sections.count-1] withRowAnimation:UITableViewRowAnimationFade];

    [self.tableView endUpdates];
    [self.refreshControl endRefreshing];
    /*
    for (NSDictionary *item in responseObject) {
        NSLog(@"title: %@ \n description: %@ \n date: %@",item[@"title"],item[@"description"],item[@"pubDate"]);
    }*/
}
-(void)setupCell:(ALTableViewAbstractCell *)cell inTableView:(UITableView *)tableView forRowAtIndexPath:(NSIndexPath *)indexPath{
    RUReaderTableViewRow *row = (RUReaderTableViewRow *)[self rowInTableView:tableView forIndexPath:indexPath];
    RUReaderTableViewCell *readerCell = (RUReaderTableViewCell *)cell;
    [row setupCell:readerCell];
}

/*
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    RUReaderTableViewRow *row = (RUReaderTableViewRow *)[self rowInTableView:tableView forIndexPath:indexPath];
    if (row.date) {
        return IMAGE_HEIGHT + IMAGE_BOTTOM_PADDING;
    } else {
        return IMAGE_HEIGHT;
    }
}*/
 /*
-(CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath{

    return 200*320/CGRectGetWidth(tableView.bounds);
}*/
@end
