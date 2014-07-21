//
//  ArrayDataSource.h
//  
//
//  Created by Kyle Bailey on 6/30/14.
//  Copyright (c) 2014 Kyle Bailey. All rights reserved.
//

#import "DataSource.h"

@interface BasicDataSource : DataSource
@property (nonatomic) NSArray *items;
@property (nonatomic) NSInteger numberOfItems;
@end
