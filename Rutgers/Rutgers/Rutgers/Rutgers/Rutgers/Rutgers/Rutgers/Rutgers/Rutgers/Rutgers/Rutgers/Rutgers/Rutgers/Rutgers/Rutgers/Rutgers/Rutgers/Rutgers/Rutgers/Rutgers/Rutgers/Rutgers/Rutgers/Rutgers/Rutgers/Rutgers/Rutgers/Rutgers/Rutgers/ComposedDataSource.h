//
//  ComposedDataSource.h
//  
//
//  Created by Kyle Bailey on 6/30/14.
//  Copyright (c) 2014 Kyle Bailey. All rights reserved.
//

#import "DataSource.h"

/*
    Gives out data source at a particular location

 
    Multiple Data Sources are stored in this data source 
 */


@interface ComposedDataSource : DataSource
@property (nonatomic) BOOL singleLoadingIndicator;

-(DataSource *)dataSourceAtIndex:(NSInteger)index;
-(void)addDataSource:(DataSource *)dataSource;
-(void)insertDataSource:(DataSource *)dataSource atIndex:(NSInteger)index;
-(void)removeDataSource:(DataSource *)dataSource;
-(void)removeAllDataSources;
@end