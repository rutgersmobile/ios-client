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
-(EZTableViewAbstractRow *)itemAtIndexPath:(NSIndexPath *)indexPath;
-(BOOL)shouldHighlightItemAtIndexPath:(NSIndexPath *)indexPath;
@property (nonatomic) BOOL hidesSeperatorInsets;
@end
