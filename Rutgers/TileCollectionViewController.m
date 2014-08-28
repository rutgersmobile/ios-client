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
@property (nonatomic) CGRect lastValidBounds;
@end

@implementation TileCollectionViewController
- (instancetype)init
{
    self = [super initWithCollectionViewLayout:[[RUCollectionViewFlowLayout alloc] init]];
    if (self) {

    }
    return self;
}

-(void)viewWillLayoutSubviews{
    [self invalidateLayoutIfNeeded];
}

-(void)invalidateLayoutIfNeeded{
    if (!CGRectEqualToRect(self.view.bounds, self.lastValidBounds)) [self invalidateLayout];
}

-(void)invalidateLayout{
    [self.collectionView.collectionViewLayout invalidateLayout];
    self.lastValidBounds = self.view.bounds;
}
@end
