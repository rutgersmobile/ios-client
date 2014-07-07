//
//  RUReaderController.m
//  Rutgers
//
//  Created by Kyle Bailey on 4/16/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

#import "RUReaderViewController.h"
#import <AFNetworking.h>
#import "RUReaderTableViewCell.h"
#import "RUNetworkManager.h"
#import "RUChannelManager.h"
#import "EZTableViewSection.h"
#import "RUReaderTableViewRow.h"

@interface RUReaderViewController ()
@property (nonatomic) NSDictionary *channel;
@property AFHTTPSessionManager *sessionManager;
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
    self.tableView.rowHeight = 80.0;
    self.tableView.estimatedRowHeight = 80.0;

    [self startNetworkLoad];
}

-(void)startNetworkLoad{
    [super startNetworkLoad];
    [self getURL:self.channel[@"url"]];
}

-(void)getURL:(NSString *)url{
    if (!url) return;
    [[RUNetworkManager xmlSessionManager] GET:url parameters:0 success:^(NSURLSessionDataTask *task, id responseObject) {
        if ([responseObject isKindOfClass:[NSDictionary class]]) {
            [self networkLoadSucceeded];
            NSDictionary *channel = [responseObject[@"channel"] firstObject];
            [self parseResponse:channel[@"item"]];
        } else {
            [self networkLoadFailed];
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        [self networkLoadFailed];
    }];
}

-(void)parseResponse:(NSArray *)response{
    
    [self.tableView beginUpdates];
   
    if (self.sections.count) {
        [self removeAllSections];
    }
        [self makeSectionForResponse:response];

    [self.tableView endUpdates];
}

-(void)makeSectionForResponse:(NSArray *)response{
    EZTableViewSection *section = [[EZTableViewSection alloc] init];
    for (NSDictionary *item in response) {
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
}

-(void)setupCell:(ALTableViewAbstractCell *)cell inTableView:(UITableView *)tableView forRowAtIndexPath:(NSIndexPath *)indexPath{
    RUReaderTableViewRow *row = (RUReaderTableViewRow *)[self rowInTableView:tableView forIndexPath:indexPath];
    RUReaderTableViewCell *readerCell = (RUReaderTableViewCell *)cell;
    [row setupCell:readerCell];
}
@end
