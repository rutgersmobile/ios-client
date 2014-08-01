//
//  RUSportsViewController.m
//  Rutgers
//
//  Created by Kyle Bailey on 6/9/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

#import "RUSportsViewController.h"
#import "RUSportsData.h"
#import "EZCollectionViewSection.h"
#import "TileCollectionViewItem.h"
#import "RUSportsRosterViewController.h"
#import "TileDataSource.h"

@interface RUSportsViewController ()
@property RUSportsData *sportsData;
@end

@implementation RUSportsViewController
+(instancetype)componentForChannel:(NSDictionary *)channel{
    return [[RUSportsViewController alloc] init];
}

-(void)viewDidLoad{
    [super viewDidLoad];
    [self makeSections];
}

-(void)makeSections{
    self.sportsData = [[RUSportsData alloc] init];
    
    NSDictionary *allSports = [RUSportsData allSports];
    
    NSMutableArray *items = [NSMutableArray array];
    NSArray *sports = [[allSports allKeys] sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)];
    for (NSString *sport in sports) {
        TileCollectionViewItem *item = [[TileCollectionViewItem alloc] initWithTitle:sport object:allSports[sport]];
        [items addObject:item];
    }
    self.dataSource = [[TileDataSource alloc] initWithItems:items];
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    TileCollectionViewItem *item = [self.dataSource itemAtIndexPath:indexPath];
    RUSportsRosterViewController *rosterVC = [[RUSportsRosterViewController alloc] initWithSportID:item.object];
    rosterVC.title = item.title;
    [self.navigationController pushViewController:rosterVC animated:YES];
}
@end
