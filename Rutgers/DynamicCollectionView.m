//
//  dcollection.m
//  Rutgers
//
//  Created by Kyle Bailey on 6/3/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

#import "Reader.h"
#import "RUChannelManager.h"
#import "RUNetworkManager.h"
#import "NSDictionary+Channel.h"
#import "DynamicCollectionView.h"
#import "TileCollectionViewItem.h"
#import "TileCollectionViewCell.h"
#import "EZCollectionViewSection.h"

@interface DynamicCollectionView ()
@property (nonatomic) NSDictionary *channel;
@property (nonatomic) UISlider *slider;
@end

@implementation DynamicCollectionView

+(instancetype)componentForChannel:(NSDictionary *)channel{
    return [[DynamicCollectionView alloc] initWithChannel:channel];
}

-(instancetype)initWithChannel:(NSDictionary *)channel{
    self = [self init];
    if (self) {
        self.channel = channel;
        [self fetchData];
    }
    return self;
}
-(instancetype)initWithChildren:(NSArray *)children{
    self = [self init];
    if (self) {
        [self parseResponse:children];
    }
    return self;
}
-(void)parseResponse:(id)responseObject{
    EZCollectionViewSection *section = [[EZCollectionViewSection alloc] init];
    for (NSDictionary *child in responseObject) {
        NSString *title = [child titleForChannel];
        TileCollectionViewItem *item = [[TileCollectionViewItem alloc] initWithText:title];
        if (child[@"children"]) {
            item.showsEllipses = YES;
            item.didSelectItemBlock = ^{
                DynamicCollectionView *dcvc = [[DynamicCollectionView alloc] initWithChildren:child[@"children"]];
                dcvc.title = [child titleForChannel];
                [self.navigationController pushViewController:dcvc animated:YES];
            };
        } else if (child[@"channel"]) {
            item.didSelectItemBlock = ^{
                [self.navigationController pushViewController:[[RUChannelManager sharedInstance] viewControllerForChannel:child[@"channel"]] animated:YES];
            };
        }
        [section addItem:item];
    }
    [self addSection:section];
}

-(void)fetchData{
    [[RUNetworkManager jsonSessionManager] GET:self.channel[@"url"] parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        if ([responseObject isKindOfClass:[NSDictionary class]]) {
            [self parseResponse:responseObject[@"children"]];
            [self.collectionView insertSections:[NSIndexSet indexSetWithIndex:0]];
        } else {
            [self fetchData];
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        [self fetchData];
    }];
}
@end
