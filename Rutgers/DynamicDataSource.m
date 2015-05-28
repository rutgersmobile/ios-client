//
//  DynamicDataSource.m
//  Rutgers
//
//  Created by Kyle Bailey on 8/22/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

#import "DynamicDataSource.h"
#import "ALTableViewTextCell.h"
#import "DataSource_Private.h"

@interface DynamicDataSource ()
@property NSDictionary *channel;
@end

@implementation DynamicDataSource

-(instancetype)initWithChannel:(NSDictionary *)channel{
    self = [super init];
    if (self) {
        self.channel = channel;
        
        //If the channel has children load them right away
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
    //If the channel doesnt have a url it was already loaded in init
    if (![self.channel channelURL]) return;
    
    [self loadContentWithBlock:^(AAPLLoading *loading) {
    
        [[RUNetworkManager sessionManager] GET:[self.channel channelURL] parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
            if (!loading.current) {
                //If we have started another load, we should ignore this one
                [loading ignore];
                return;
            }
            
            if ([responseObject isKindOfClass:[NSDictionary class]]) {
                //Update with the response
                NSArray *items = responseObject[@"children"];
                [loading updateWithContent:^(typeof(self) me) {
                    me.items = items;
                }];
            } else {
                //Clear the items
                [loading updateWithNoContent:^(typeof(self) me) {
                    me.items = nil;
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

-(NSString *)reuseIdentifierForRowAtIndexPath:(NSIndexPath *)indexPath{
    return NSStringFromClass([ALTableViewTextCell class]);
}

-(void)configureCell:(ALTableViewTextCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    
    id itemForIndex = [self itemAtIndexPath:indexPath];
    
    if ([itemForIndex isKindOfClass:[NSString class]]) {
        //If it is a string display it
        cell.textLabel.text = itemForIndex;
        cell.accessoryType = UITableViewCellAccessoryNone;
    } else if ([itemForIndex isKindOfClass:[NSDictionary class]]) {
        //If it is a channel display its title with a disclosure indicator
        cell.textLabel.text = [itemForIndex channelTitle];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
}

@end
