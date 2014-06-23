//
//  DynamicTableViewController.m
//  Rutgers
//
//  Created by Kyle Bailey on 4/16/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

#import "dtable.h"
#import "Reader.h"
#import "RUChannelManager.h"
#import "RUNetworkManager.h"
#import "NSDictionary+Channel.h"
#import "EZTableViewSection.h"
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
    }
    return self;
}
-(void)viewDidLoad{
    [super viewDidLoad];
    
    if (self.children) {
        [self parseResponse:self.children];
    } else {
        [self fetchData];
    }
}

-(void)parseResponse:(id)responseObject{
    [self.tableView beginUpdates];
    if (self.sections.count) {
        [self removeAllSections];
        [self.tableView deleteSections:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, self.sections.count)] withRowAnimation:UITableViewRowAnimationFade];
    }
    EZTableViewSection *section = [[EZTableViewSection alloc] init];
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
        [section addRow:row];
    }
    [self addSection:section];
    [self.tableView insertSections:[NSIndexSet indexSetWithIndex:self.sections.count-1] withRowAnimation:UITableViewRowAnimationFade];
    [self.tableView endUpdates];
}

-(void)fetchData{
    [[RUNetworkManager jsonSessionManager] GET:self.channel[@"url"] parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        if ([responseObject isKindOfClass:[NSDictionary class]]) {
            [self parseResponse:responseObject[@"children"]];
        } else {
            [self fetchData];
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        [self fetchData];
    }];
}
@end
