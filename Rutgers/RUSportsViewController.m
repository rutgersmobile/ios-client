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

@interface RUSportsViewController ()
@property RUSportsData *sportsData;
@end

@implementation RUSportsViewController
+(instancetype)componentForChannel:(NSDictionary *)channel{
    return [[RUSportsViewController alloc] init];
}

- (instancetype)init
{
    self = [super init];
    if (self) {

    }
    return self;
}

-(void)viewDidLoad{
    [super viewDidLoad];
    [self makeSections];
}

-(void)makeSections{
    self.sportsData = [[RUSportsData alloc] init];
    
    NSDictionary *allSports = [RUSportsData allSports];
    
    EZCollectionViewSection *section = [[EZCollectionViewSection alloc] init];
    NSArray *sports = [[allSports allKeys] sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)];
    for (NSString *sport in sports) {
        TileCollectionViewItem *item = [[TileCollectionViewItem alloc] initWithText:sport];
        item.didSelectItemBlock = ^ {
            RUSportsRosterViewController *rosterVC = [[RUSportsRosterViewController alloc] initWithSportID:allSports[sport]];
            rosterVC.title = sport;
            [self.navigationController pushViewController:rosterVC animated:YES];
        };
        [section addItem:item];
    }
    [self addSection:section];
}
@end
