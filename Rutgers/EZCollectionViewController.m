//
//  EZCollectionViewController.m
//  Rutgers
//
//  Created by Kyle Bailey on 6/3/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

#import "EZCollectionViewController.h"
#import "EZCollectionViewSection.h"
#import "EZCollectionViewItem.h"
#import "EZCollectionViewCell.h"

@interface EZCollectionViewController () <UICollectionViewDelegateFlowLayout>
@property (nonatomic) NSMutableArray *sections;
@end

@implementation EZCollectionViewController

- (instancetype)init
{
    self = [super initWithCollectionViewLayout:[[UICollectionViewFlowLayout alloc] init]];
    if (self) {
        self.sections = [NSMutableArray array];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.collectionView.backgroundColor = [UIColor groupTableViewBackgroundColor];
    [self.collectionView registerClass:[EZCollectionViewCell class] forCellWithReuseIdentifier:@"EZCollectionViewCell"];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)addSection:(EZCollectionViewSection *)section{
    [self.sections addObject:section];
}

-(void)insertSection:(EZCollectionViewSection *)section atIndex:(NSInteger)index{
    [self.sections insertObject:section atIndex:index];
}

-(void)removeAllSections{
    NSInteger count = self.sections.count;
    [self.sections removeAllObjects];
    [self.collectionView deleteSections:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, count)]];
}

- (EZCollectionViewSection *)sectionAtIndex:(NSInteger)section{
    return self.sections[section];
}

- (EZCollectionViewItem *)itemForIndexPath:(NSIndexPath *)indexPath{
    return [[self sectionAtIndex:indexPath.section] itemAtIndex:indexPath.row];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return [[self sectionAtIndex:section] numberOfItems];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    EZCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:[self itemForIndexPath:indexPath].identifier forIndexPath:indexPath];
    [self setupCell:cell inCollectionView:collectionView forItemAtIndexPath:indexPath];
    return cell;
    
}

BOOL iPad() {
    static bool iPad = NO;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        iPad = (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad);
    });
    return iPad;
}

#define iPad iPad()

#define TILE_PADDING 4
#define TILE_SPACING 3

#define MAX_TILE_WIDTH  (iPad ? 180.0 : 120.0)
#define FONT_SIZE  (iPad ? 20 : 16.0)

-(void)setupCell:(EZCollectionViewCell *)cell inCollectionView:(UICollectionView *)collectionView forItemAtIndexPath:(NSIndexPath *)indexPath{
    [[self itemForIndexPath:indexPath] setupCell:cell];
    cell.textLabel.font = [UIFont systemFontOfSize:FONT_SIZE];
}

#pragma mark - CollectionViewFlowLayout Delegate

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    CGFloat layoutWidth = CGRectGetWidth(collectionView.bounds)-TILE_PADDING*2;
    NSInteger number = 0;
    CGFloat width = 0;
    
    while (width < layoutWidth) {
        number++;
        width += MAX_TILE_WIDTH + TILE_SPACING;
    }
    
    CGFloat tileWidth = (layoutWidth - (number-1)*TILE_SPACING) / number;
    return CGSizeMake(floorf(tileWidth), floorf(tileWidth*170.0/203.0));
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section{
    return UIEdgeInsetsMake(TILE_PADDING, TILE_PADDING, TILE_PADDING, TILE_PADDING);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section{
    return TILE_SPACING;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section{
    return TILE_SPACING;
}

#pragma mark - CollectionView Delegate

-(BOOL)collectionView:(UICollectionView *)collectionView shouldHighlightItemAtIndexPath:(NSIndexPath *)indexPath{
    return [self itemForIndexPath:indexPath].shouldHighlight;

}
-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    EZCollectionViewItem *item = [self itemForIndexPath:indexPath];
    if (item.didSelectRowBlock) {
        item.didSelectRowBlock();
    }
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return self.sections.count;
}

-(void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration{
    [super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
    [self.collectionViewLayout invalidateLayout];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.collectionViewLayout invalidateLayout];
}
@end
