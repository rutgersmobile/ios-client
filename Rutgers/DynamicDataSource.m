//
//  DynamicDataSource.m
//  Rutgers
//
//  Created by Kyle Bailey on 7/29/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

#import "DynamicDataSource.h"
#import "RUNetworkManager.h"

@interface DynamicDataSource ()
@property NSString *url;
@property BOOL wasInitializedWithItems;
@end
@implementation DynamicDataSource
- (instancetype)initWithUrl:(NSString *)url
{
    self = [super init];
    if (self) {
        self.url = url;
    }
    return self;
}

-(id)initWithItems:(NSArray *)items{
    self = [super init];
    if (self) {
        [self parseItems:items];
        self.wasInitializedWithItems = YES;
    }
    return self;
}

-(void)loadContent{
    if (!self.wasInitializedWithItems) {
        [self loadContentWithBlock:^(AAPLLoading *loading) {
            [[RUNetworkManager jsonSessionManager] GET:self.url parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
                if ([responseObject isKindOfClass:[NSDictionary class]]) {
                    [loading updateWithContent:^(typeof(self) me) {
                        [me parseItems:responseObject[@"children"]];
                    }];
                } else {
                    [loading doneWithError:nil];
                }
            } failure:^(NSURLSessionDataTask *task, NSError *error) {
                [loading doneWithError:error];
            }];
        }];
    }
}

-(void)parseItems:(NSArray *)items{
    NSMutableArray *parsedItems = [NSMutableArray array];
    for (NSDictionary *item in items) {
        TileCollectionViewItem *parsedItem = [[TileCollectionViewItem alloc] initWithTitle:[item titleForChannel] object:item];
        if ([self typeOfItem:parsedItem] != kDynamicItemTypeChannel) parsedItem.showsEllipses = YES;
        [parsedItems addObject:parsedItem];
    }
    self.items = parsedItems;
}

-(kDynamicItemType)typeOfItem:(TileCollectionViewItem *)item{
    return [self typeOfChild:item.object];
}

-(kDynamicItemType)typeOfChild:(NSDictionary *)child{
    NSDictionary *channel = child[@"channel"];
    if (channel) {
        return kDynamicItemTypeChannel;
    } else {
        if (child[@"answer"]) return kDynamicItemTypeFaq;
        NSArray *children = child[@"children"];
        for (NSDictionary *child in children) {
            kDynamicItemType type = [self typeOfChild:child];
            if (type == kDynamicItemTypeFaq) return type;
        }
        return kDynamicItemTypeList;
    }
}

@end
