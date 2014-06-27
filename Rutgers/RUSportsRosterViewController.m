//
//  RUSportsRosterViewController.m
//  Rutgers
//
//  Created by Kyle Bailey on 6/10/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

#import "RUSportsRosterViewController.h"
#import "RUPlayerCell.h"
#import "RUSportsData.h"
#import "EZCollectionViewSection.h"
#import "RUPlayerItem.h"
#import "RUSportsPlayer.h"
#import "RUSportsPlayerViewController.h"
#import "iPadCheck.h"

@interface RUSportsRosterViewController ()
@property NSString *sportID;
@end

@implementation RUSportsRosterViewController

-(id)initWithSportID:(NSString *)sportID{
    self = [super init];
    if (self) {
        self.sportID = sportID;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.maxTileWidth = iPad() ? 180.0 : 130;
    self.tileAspectRatio = 2.0/3.0;
    self.tileSpacing = 4;
    self.tilePadding = 4;
    [self.collectionView registerClass:[RUPlayerCell class] forCellWithReuseIdentifier:@"RUPlayerCardCell"];
    
    [self startNetworkLoad];
}
-(void)startNetworkLoad{
    [super startNetworkLoad];
    [RUSportsData getRosterForSportID:self.sportID withSuccess:^(NSArray *response) {
        EZCollectionViewSection *section = [[EZCollectionViewSection alloc] init];
        for (NSDictionary *playerDictionary in response) {
            RUSportsPlayer *player = [[RUSportsPlayer alloc] initWithDictionary:playerDictionary];
            RUPlayerItem *playerItem = [[RUPlayerItem alloc] initWithSportsPlayer:player];
            playerItem.didSelectItemBlock = ^ {
                [self.navigationController pushViewController:[[RUSportsPlayerViewController alloc] initWithPlayer:player] animated:YES];
            };
            [section addItem:playerItem];
        }
        [self addSection:section];
        [self.collectionView insertSections:[NSIndexSet indexSetWithIndex:0]];
        [self networkLoadSucceeded];
    } failure:^{
        [self networkLoadFailed];
    }];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
