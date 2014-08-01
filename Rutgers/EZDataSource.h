//
//  EZTableViewDataSource.h
//  Rutgers
//
//  Created by Kyle Bailey on 7/21/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

#import "ComposedDataSource.h"
#import "EZDataSourceSection.h"

@interface EZDataSource : ComposedDataSource <UICollectionViewDelegate, UITableViewDelegate>
-(void)addSection:(EZDataSourceSection *)section;
-(void)insertSection:(EZDataSourceSection *)section atIndex:(NSInteger)index;
//-(void)replaceSection:(EZDataSourceSection *)oldSection withSection:(EZDataSourceSection *)newSection;
-(void)reloadSection:(EZDataSourceSection *)section;
-(void)reloadSectionAtIndex:(NSInteger)index;
-(void)removeAllSections;

-(NSInteger)indexOfSection:(EZDataSourceSection *)section;
-(EZDataSourceSection *)sectionAtIndex:(NSInteger)index;
-(EZTableViewAbstractRow *)itemAtIndexPath:(NSIndexPath *)indexPath;
-(BOOL)shouldHighlightItemAtIndexPath:(NSIndexPath *)indexPath;
@end
