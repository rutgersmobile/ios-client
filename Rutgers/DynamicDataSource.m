//
//  DynamicDataSource.m
//  Rutgers
//
//  Created by Kyle Bailey on 8/22/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

#import "DynamicDataSource.h"
#import "ALTableViewTextCell.h"

@interface DynamicDataSource ()
@property NSDictionary *channel;
@end

@implementation DynamicDataSource

-(instancetype)initWithChannel:(NSDictionary *)channel{
    self = [super init];
    if (self) {
        self.channel = channel;
        
        NSArray *children = channel[@"children"];
        if (children) {
            [self loadContentWithBlock:^(AAPLLoading *loading) {
                [loading updateWithContent:^(typeof(self) me) {
                    me.items = children;
                }];
            }];
        }
    }
    return self;
}

-(void)loadContent{
    if (![self.channel channelURL]) return;
    [self loadContentWithBlock:^(AAPLLoading *loading) {
    
        [[RUNetworkManager sessionManager] GET:[self.channel channelURL] parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
            if (!loading.current) {
                [loading ignore];
                return;
            }
            if ([responseObject isKindOfClass:[NSDictionary class]]) {
                NSArray *items = responseObject[@"children"];
                if (items.count) {
                    [loading updateWithContent:^(typeof(self) me) {
                        me.items = items;
                    }];
                } else {
                    [loading updateWithNoContent:^(typeof(self) me) {
                        me.items = items;
                    }];
                }
            } else {
                [loading doneWithError:nil];
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

-(NSString *)reuseIdentifierForRowAtIndexPath:(NSIndexPath *)indexPath{
    return NSStringFromClass([ALTableViewTextCell class]);
}

-(void)configureCell:(ALTableViewTextCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
   // [super configureCell:cell forRowAtIndexPath:indexPath];
    
    NSString *stringForIndex;
    id itemForIndex = [self itemAtIndexPath:indexPath];
    
    if ([itemForIndex isKindOfClass:[NSString class]]) {
        stringForIndex = itemForIndex;
        cell.accessoryType = UITableViewCellAccessoryNone;
        
    } else if ([itemForIndex isKindOfClass:[NSDictionary class]]) {
        stringForIndex = [itemForIndex channelTitle];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    cell.textLabel.text = stringForIndex;
}

@end
