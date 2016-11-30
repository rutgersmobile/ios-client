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
#import "RUNetworkManager.h"
#import "NSDictionary+Channel.h"

#warning TODO : creating two seperate classes . DataSource for the tableViewController and the DataSource for the CollectionViewController

@implementation DynamicDataSource

-(instancetype)initWithChannel:(NSDictionary *)channel
{
    return [self initWithChannel:channel forLayout:NO];
}

-(instancetype)initWithChannel:(NSDictionary *)channel forLayout:(BOOL)layout
{
    self = [super init];
    if (self) {
        self.channel = channel;
        
        //If the channel has children load them right away
        NSArray *children = channel[@"children"];
        if (children)
        {
            [self loadContentWithBlock:^(AAPLLoading *loading)
            {
                [loading updateWithContent:^(typeof(self) me) {
                    me.items = children;
                }];
            }];
            
            if(layout)
            {
                self.items = children;
            }
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
                NSArray * bannerItems = responseObject[@"banner"];
                [loading updateWithContent:^(typeof(self) me) {
                    me.items = items;
                    me.bannerItems= bannerItems;
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

/*
    Load the content without the state machine . Update the values and do the completeion block
    No error handling for now , but more complex features will be added...
 */
-(void)loadContentWithAnyBlock:(void(^)(void)) completionBlock
{
    if (![self.channel channelURL])
    {
        completionBlock();
        return ;
    }

        [[RUNetworkManager sessionManager] GET:[self.channel channelURL] parameters:nil success:^(NSURLSessionDataTask *task, id responseObject)
        {
            if ([responseObject isKindOfClass:[NSDictionary class]])
            {
                //Update with the response
                NSArray *items = responseObject[@"children"];
                self.items = items;
                
                NSArray *bannerItems = responseObject[@"banner"];
                self.bannerItems = bannerItems;
            }
            else
            {
                //Clear the items
                self.items = nil;
                self.bannerItems = nil;
            }
            
            completionBlock();
        }
        failure:^(NSURLSessionDataTask * task, NSError * error)
        {
            self.items = nil ;
            self.bannerItems = nil;
        }];
    
   // run the completion block
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
