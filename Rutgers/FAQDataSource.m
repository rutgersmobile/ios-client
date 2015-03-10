//
//  FAQDataSource.m
//  Rutgers
//
//  Created by Kyle Bailey on 7/31/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

#import "FAQDataSource.h"
#import "ALTableViewTextCell.h"
#import "ExpandingTableViewSection.h"
#import "FAQSectionDataSource.h"

@interface FAQDataSource ()
@property NSDictionary *channel;
@end

@implementation FAQDataSource
-(instancetype)initWithChannel:(NSDictionary *)channel{
    self = [super init];
    if (self) {
        self.channel = channel;
        
        //If the channel has children load them right away
        NSArray *children = channel[@"children"];
        if (children) {
            [self loadContentWithBlock:^(AAPLLoading *loading) {
                [loading updateWithContent:^(typeof(self) me) {
                    [me updateWithItems:children];
                }];
            }];
        }
    }
    return self;
}

-(void)updateWithItems:(NSArray *)items{
    NSMutableArray *sections = [NSMutableArray array];
    for (NSDictionary *item in items) {
        [sections addObject:[[FAQSectionDataSource alloc] initWithItem:item]];
    }
    self.sections = sections;
}

-(void)loadContent{
    //If the channel doesnt have a url it was already loaded in init
    if (![self.channel channelURL]) return;
    
    [self loadContentWithBlock:^(AAPLLoading *loading) {
        
        [[RUNetworkManager sessionManager] GET:[self.channel channelURL] parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
            if (!loading.current) {
                [loading ignore];
                return;
            }
            if ([responseObject isKindOfClass:[NSDictionary class]]) {
                [loading updateWithContent:^(typeof(self) me) {
                    [me updateWithItems:responseObject[@"children"]];
                }];
            } else {
                [loading updateWithNoContent:^(typeof(self) me) {
                    [me updateWithItems:nil];
                }];
            }
        } failure:^(NSURLSessionDataTask *task, NSError *error) {
            if (!loading.current) {
                [loading ignore];
                return;
            }
            [loading doneWithError:error];
        }];

    }];
}

-(void)registerReusableViewsWithTableView:(UITableView *)tableView{
    [super registerReusableViewsWithTableView:tableView];
    [tableView registerClass:[ALTableViewTextCell class] forCellReuseIdentifier:NSStringFromClass([ALTableViewTextCell class])];
}

@end
