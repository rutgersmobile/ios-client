//
//  CardCollectionViewController.m
//  Rutgers
//
//  Created by Kyle Bailey on 6/10/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

#import "CardCollectionViewController.h"
#import "EZCollectionViewSection.h"

@interface CardCollectionViewController ()
@property (nonatomic) int currentIndex;
@property (nonatomic) UIScrollView *secretScrollView;
@property (nonatomic) UIView *headerView;
@property (nonatomic) UIView *footerView;
@end

@implementation CardCollectionViewController

#define PAGE_INSETS UIEdgeInsetsMake(0, 30, 0, 30)

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.headerView = [UIView newAutoLayoutView];
    [self.view addSubview:self.headerView];
    
    [self.headerView autoSetDimension:ALDimensionHeight toSize:70];
    [self.headerView autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsZero excludingEdge:ALEdgeBottom];
    self.headerView.backgroundColor = [UIColor lightGrayColor];
    
    self.footerView = [UIView newAutoLayoutView];
    [self.view addSubview:self.footerView];
    self.footerView.backgroundColor = [UIColor lightGrayColor];
    
    [self.collectionView autoRemoveConstraintsAffectingView];
    [self.collectionView autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:0];
    [self.collectionView autoPinEdgeToSuperviewEdge:ALEdgeRight withInset:0];
    [self.collectionView autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:self.headerView];
    [self.collectionView autoSetDimension:ALDimensionHeight toSize:160];
    
    [self.footerView autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:self.collectionView];
    [self.footerView autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsZero excludingEdge:ALEdgeTop];
    
    self.secretScrollView = [UIScrollView newAutoLayoutView];
    //self.secretScrollView.hidden = YES;
    [self.view addSubview:self.secretScrollView];
    self.secretScrollView.userInteractionEnabled = NO;
    self.secretScrollView.delegate = self;
    self.secretScrollView.pagingEnabled = YES;
    [self.secretScrollView autoPinEdge:ALEdgeTop toEdge:ALEdgeTop ofView:self.collectionView];
    [self.secretScrollView autoPinEdge:ALEdgeBottom toEdge:ALEdgeBottom ofView:self.collectionView];
    [self.secretScrollView autoMatchDimension:ALDimensionHeight toDimension:ALDimensionWidth ofView:self.secretScrollView];
    [self.secretScrollView autoAlignAxisToSuperviewAxis:ALAxisVertical];

    self.flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    self.flowLayout.minimumInteritemSpacing = 0;
    self.flowLayout.minimumLineSpacing = 0;
    self.edgesForExtendedLayout = UIRectEdgeNone;
    
    self.collectionView.panGestureRecognizer.enabled = NO;
    [self.collectionView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)]];
    [self.collectionView addGestureRecognizer:self.secretScrollView.panGestureRecognizer];
}

-(void)handleTap:(UITapGestureRecognizer *)tapGestureRecognizer{
    CGPoint tap = [tapGestureRecognizer locationInView:self.view];
    CGFloat center = CGRectGetMidX(self.collectionView.frame);
    CGFloat distance = tap.x - center;
    NSInteger itemsToScroll = round(distance/[self pageSize].width);
    
    CGPoint offset =  self.secretScrollView.contentOffset;
    offset.x += itemsToScroll*[self pageSize].width;
    if (offset.x < 0) return;
    if (offset.x + [self pageSize].width > [self contentSize].width) return;
    NSLog(@"%ld",(long)itemsToScroll);
    NSLog(@"%f",offset.x);
    [self.secretScrollView setContentOffset:offset animated:YES];
}

-(void)viewDidLayoutSubviews{
    [super viewDidLayoutSubviews];
    self.collectionView.contentInset = UIEdgeInsetsMake(0, [self leftOffset], 0, [self leftOffset]);
}

-(void)addSection:(EZCollectionViewSection *)section{
    [super addSection:section];
    [self updateScrollBounds];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
    if (scrollView == self.secretScrollView) {
        CGPoint contentOffset = scrollView.contentOffset;
        contentOffset.x = contentOffset.x - [self leftOffset];
        self.collectionView.contentOffset = contentOffset;
    } else if (scrollView == self.collectionView) {
        [self transformCells];
    }
}

-(void)transformCells{
    CGFloat halfWidth = CGRectGetWidth(self.collectionView.bounds)/2.0;
    CGFloat center  = self.collectionView.contentOffset.x+halfWidth;
    
    for (UICollectionViewCell *cell in self.collectionView.visibleCells) {
        CGFloat distance = center-cell.center.x;
        CGFloat scaleRatio = 1-0.3*ABS(distance/halfWidth);
        cell.layer.transform = CATransform3DMakeAffineTransform(CGAffineTransformMakeScale(scaleRatio, scaleRatio));
    }
}
-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return [self pageSize];
}

#pragma mark -
#pragma mark Rotation handling methods

-(void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:
(NSTimeInterval)duration {
    
    // Fade the collectionView out
    [self.collectionView setAlpha:0.0f];

    [self.collectionView.collectionViewLayout invalidateLayout];

    // Calculate the index of the item that the collectionView is currently displaying
    CGFloat currentOffset = [self.collectionView contentOffset].x+[self leftOffset];
    CGSize currentSize = [self pageSize];

    self.currentIndex = currentOffset / currentSize.width;
    NSLog(@"%d",self.currentIndex);
}

-(void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
    
    // Force realignment of cell being displayed
    CGSize currentSize = [self pageSize];
    float offset = self.currentIndex * currentSize.width - [self leftOffset];
    
    [self updateScrollBounds];
    [self.collectionView setContentOffset:CGPointMake(offset, -self.collectionView.contentInset.top)];

    [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        [self.collectionView setAlpha:1];
    } completion:^(BOOL finished) {
        
    }];
    
}

-(CGSize)pageSize{
    return self.secretScrollView.bounds.size;
}
-(CGSize)contentSize{
    CGSize pageSize = [self pageSize];
    return CGSizeMake(pageSize.width*[self sectionAtIndex:0].numberOfItems, pageSize.height);
}
-(CGFloat)leftOffset{
    return CGRectGetMinX(self.secretScrollView.frame);
}
-(void)updateScrollBounds{
    [self transformCells];
     self.secretScrollView.contentSize = [self contentSize];
}
@end
