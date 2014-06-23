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
#import "ColoredTileCollectionViewItem.h"
#import "ColoredTileCollectionViewCell.h"
#import "EZCollectionViewSection.h"
#import "FAQViewController.h"

typedef enum : NSUInteger {
    kChildTypeChannel,
    kChildTypeList,
    kChildTypeFaq,
    kChildTypeUnknown
} kChildType;

@interface DynamicCollectionView ()
@property (nonatomic) NSDictionary *channel;
@property (nonatomic) NSArray *children;
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
    EZCollectionViewSection *section = [[EZCollectionViewSection alloc] init];
    for (NSDictionary *child in responseObject) {
        NSString *title = [child titleForChannel];
        ColoredTileCollectionViewItem *item = [[ColoredTileCollectionViewItem alloc] initWithText:title];
        kChildType type = [self typeOfChild:child];
        if (type == kChildTypeChannel) {
            item.didSelectItemBlock = ^{
                [self.navigationController pushViewController:[[RUChannelManager sharedInstance] viewControllerForChannel:child[@"channel"]] animated:YES];
            };
        } else if (type == kChildTypeList) {
            item.showsEllipses = YES;
            item.didSelectItemBlock = ^{
                DynamicCollectionView *dcVC = [[DynamicCollectionView alloc] initWithChildren:child[@"children"]];
                dcVC.title = [child titleForChannel];
                [self.navigationController pushViewController:dcVC animated:YES];
            };
        } else if (type == kChildTypeFaq) {
            item.didSelectItemBlock = ^{
                FAQViewController *faqVC = [[FAQViewController alloc] initWithChildren:child[@"children"]];
                faqVC.title = [child titleForChannel];
                [self.navigationController pushViewController:faqVC animated:YES];
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

-(kChildType)typeOfChild:(NSDictionary *)child{
    NSDictionary *channel = child[@"channel"];
    if (channel) {
        return kChildTypeChannel;
    } else {
        if (child[@"answer"]) return kChildTypeFaq;
        NSArray *children = child[@"children"];
        for (NSDictionary *child in children) {
            kChildType type = [self typeOfChild:child];
            if (type == kChildTypeFaq) return type;
        }
        return kChildTypeList;
    }
    return kChildTypeUnknown;
}
@end
