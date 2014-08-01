//
//  ArrayDataSource.h
//  
//
//  Created by Kyle Bailey on 6/30/14.
//  Copyright (c) 2014 Kyle Bailey. All rights reserved.
//

#import "DataSource.h"

@interface BasicDataSource : DataSource
-(instancetype)initWithItems:(NSArray *)items;
@property (nonatomic) NSArray *items;
@property NSInteger itemLimit;

-(NSInteger)numberOfItems;
@end
