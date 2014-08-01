//
//  DynamicTableViewController.m
//  Rutgers
//
//  Created by Kyle Bailey on 4/16/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

#import "dtable.h"
#import "RUReaderViewController.h"
#import "RUChannelManager.h"
#import "RUNetworkManager.h"
#import "NSDictionary+Channel.h"
#import "EZDataSource.h"
#import "EZTableViewRightDetailRow.h"

@interface dtable ()
@property (nonatomic) NSDictionary *channel;
@property (nonatomic) NSArray *children;
@end

@implementation dtable
+(instancetype)componentForChannel:(NSDictionary *)channel{
    return [[dtable alloc] initWithChannel:channel];
}


-(instancetype)initWithChannel:(NSDictionary *)channel{
    self = [self init];
    if (self) {
        self.channel = channel;
    }
    return self;
}
-(instancetype)initWithChildren:(NSArray *)children{
    self = [self init];
    if (self) {
        self.children = children;
        [self parseResponse:self.children];
    }
    return self;
}
-(void)viewDidLoad{
    [super viewDidLoad];
    
}

-(void)loadNetworkData{
    [[RUNetworkManager jsonSessionManager] GET:self.channel[@"url"] parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        if ([responseObject isKindOfClass:[NSDictionary class]]) {
            [self parseResponse:responseObject[@"children"]];
        } else {
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
    }];
}

-(void)parseResponse:(id)responseObject{
    [self.tableView beginUpdates];
    [self.dataSource removeAllSections];
    EZDataSourceSection *section = [[EZDataSourceSection alloc] init];
    for (NSDictionary *child in responseObject) {
        NSString *title = [child titleForChannel];
        EZTableViewRightDetailRow *row = [[EZTableViewRightDetailRow alloc] initWithText:title];
        
        if (child[@"children"]) {
            row.didSelectRowBlock = ^{
                dtable *dtvc = [[dtable alloc] initWithChildren:child[@"children"]];
                dtvc.title = [child titleForChannel];
                [self.navigationController pushViewController:dtvc animated:YES];
            };
        } else if (child[@"channel"]) {
            row.didSelectRowBlock = ^{
                [self.navigationController pushViewController:[[RUChannelManager sharedInstance] viewControllerForChannel:child[@"channel"]] animated:YES];
            };
        }
        [section addItem:row];
    }
    [self.dataSource addSection:section];
    [self.tableView endUpdates];
}
@end
