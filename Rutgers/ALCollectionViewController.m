//
//  AutoLayoutCollectionViewController.m
//  Rutgers
//
//  Created by Kyle Bailey on 6/16/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

#import "ALCollectionViewController.h"
#import "ALCollectionViewAbstractCell.h"

@interface ALCollectionViewController ()
@property (nonatomic) NSMutableDictionary *layoutCells;
@end

@implementation ALCollectionViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    self.flowLayout = flowLayout;
    // Set up the collection view with no scrollbars, paging enabled
    // and the delegate and data source set to this view controller
    self.collectionView = [[UICollectionView alloc] initWithFrame:self.view.frame collectionViewLayout:flowLayout];
    self.collectionView.translatesAutoresizingMaskIntoConstraints = NO;
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    
    self.view.backgroundColor = [UIColor groupTableViewBackgroundColor];
    [self.view addSubview:self.collectionView];
    [self.collectionView autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsZero];
    
    self.collectionView.backgroundColor = [UIColor groupTableViewBackgroundColor];
    self.collectionView.opaque = YES;
}

-(NSString *)identifierForRowInCollectionView:(UICollectionView *)collectionView atIndexPath:(NSIndexPath *)indexPath{
    [NSException raise:@"Must override abstract methods in ALTableview" format:nil];
    return nil;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    NSString *identifier = [self identifierForRowInCollectionView:collectionView atIndexPath:indexPath];
    ALCollectionViewAbstractCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
    if (!cell) {
        
    }
    [self setupCell:cell inCollectionView:collectionView forItemAtIndexPath:indexPath];
    [cell setNeedsUpdateConstraints];
    [cell updateConstraintsIfNeeded];
   
    return cell;
}

-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    ALCollectionViewAbstractCell *layoutCell = [self layoutCellWithIdentifier:[self identifierForRowInCollectionView:collectionView atIndexPath:indexPath]];
    
    [self setupCell:layoutCell inCollectionView:collectionView forItemAtIndexPath:indexPath];
    [layoutCell setNeedsUpdateConstraints];
    [layoutCell updateConstraintsIfNeeded];
    
   // layoutCell.bounds = CGRectMake(0.0f, 0.0f, CGRectGetWidth(tableView.bounds), CGRectGetHeight(layoutCell.bounds));
    [layoutCell setNeedsLayout];
    [layoutCell layoutIfNeeded];
    
    CGSize size = [layoutCell.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize];
    size.height += 1.0;
    size.width += 1.0;
    
    return size;
}

-(void)setupCell:(ALCollectionViewAbstractCell *)cell inCollectionView:(UICollectionView *)collectionView forItemAtIndexPath:(NSIndexPath *)indexPath{
    [NSException raise:@"Must override abstract methods in ALTableview" format:nil];
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return 0;
}

-(ALCollectionViewAbstractCell *)layoutCellWithIdentifier:(NSString *)identifier{
    ALCollectionViewAbstractCell *cell = self.layoutCells[identifier];
    if (!cell) {
        cell = [[NSClassFromString(identifier) alloc] init];
        self.layoutCells[identifier] = cell;
    }
    return cell;
}



@end
