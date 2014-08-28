//
//  ComposedDataSource.h
//  
//
//  Created by Kyle Bailey on 6/30/14.
//  Copyright (c) 2014 Kyle Bailey. All rights reserved.
//

#import "DataSource.h"

@interface ComposedDataSource : DataSource
-(DataSource *)dataSourceAtIndex:(NSInteger)index;
-(void)addDataSource:(DataSource *)dataSource;
-(void)insertDataSource:(DataSource *)dataSource atIndex:(NSInteger)index;
-(void)removeDataSource:(DataSource *)dataSource;
-(void)removeAllDataSources;
@end