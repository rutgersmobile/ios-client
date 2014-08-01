//
//  dcollection.m
//  Rutgers
//
//  Created by Kyle Bailey on 6/3/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

#import "RUReaderViewController.h"
#import "RUChannelManager.h"
#import "RUNetworkManager.h"
#import "NSDictionary+Channel.h"
#import "DynamicCollectionViewController.h"
#import "TileCollectionViewItem.h"
#import "TileCollectionViewCell.h"
#import "EZCollectionViewSection.h"
#import "DynamicDataSource.h"
#import "FAQViewController.h"

@interface DynamicCollectionViewController ()
@property (nonatomic) NSDictionary *channel;
@property (nonatomic) NSArray *children;
@end

@implementation DynamicCollectionViewController

+(instancetype)componentForChannel:(NSDictionary *)channel{
    return [[DynamicCollectionViewController alloc] initWithChannel:channel];
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
    if (self.channel) {
        self.dataSource = [[DynamicDataSource alloc] initWithUrl:self.channel[@"url"]];
    } else if (self.children) {
        self.dataSource = [[DynamicDataSource alloc] initWithItems:self.children];
    }
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    TileCollectionViewItem *item = [self.dataSource itemAtIndexPath:indexPath];
    kDynamicItemType type = [((DynamicDataSource *)self.dataSource) typeOfItem:item];
 
    if (type == kDynamicItemTypeChannel) {
        [self.navigationController pushViewController:[[RUChannelManager sharedInstance] viewControllerForChannel:item.object[@"channel"]] animated:YES];
    } else if (type == kDynamicItemTypeList) {
        DynamicCollectionViewController *dcVC = [[DynamicCollectionViewController alloc] initWithChildren:item.object[@"children"]];
        dcVC.title = item.title;
        [self.navigationController pushViewController:dcVC animated:YES];
    } else if (type == kDynamicItemTypeFaq) {
        FAQViewController *faqVC = [[FAQViewController alloc] initWithChildren:item.object[@"children"]];
        faqVC.title = item.title;
        [self.navigationController pushViewController:faqVC animated:YES];
    }
}

@end
