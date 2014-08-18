//
//  TileCollectionViewController.m
//  Rutgers
//
//  Created by Kyle Bailey on 6/10/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

#import "TileCollectionViewController.h"
#import "RUCollectionViewFlowLayout.h"

@interface TileCollectionViewController ()

@end

@implementation TileCollectionViewController
- (instancetype)init
{
    self = [super initWithCollectionViewLayout:[[RUCollectionViewFlowLayout alloc] init]];
    if (self) {

    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationDidBecomeActive:)
                                                 name:UIApplicationDidBecomeActiveNotification
                                               object:nil];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.collectionView.collectionViewLayout invalidateLayout];
}

-(void)applicationDidBecomeActive:(NSNotification *)notification{
    [self.collectionView.collectionViewLayout invalidateLayout];
}
@end
