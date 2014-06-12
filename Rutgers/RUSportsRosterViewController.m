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
#import "iPadCheck.h"

@interface RUSportsRosterViewController ()
@end

@implementation RUSportsRosterViewController

-(id)initWithSportID:(NSString *)sportID{
    self = [super init];
    if (self) {
        [RUSportsData getRosterForSportID:sportID withCompletion:^(NSArray *response) {
            EZCollectionViewSection *section = [[EZCollectionViewSection alloc] init];
            for (NSDictionary *player in response) {
                RUPlayerItem *playerItem = [[RUPlayerItem alloc] initWithDictionary:player];
                [section addItem:playerItem];
            }
            [self addSection:section];
            [self.collectionView insertSections:[NSIndexSet indexSetWithIndex:0]];
        }];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.maxTileWidth = iPad() ? 230.0 : 175.0;
    self.tileAspectRatio = 2.0/3.0;
    self.tileSpacing = 4;
    self.tilePadding = 4;
    [self.collectionView registerClass:[RUPlayerCell class] forCellWithReuseIdentifier:@"RUPlayerCardCell"];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
