//
//  ComposedDataSource.h
//  
//
//  Created by Kyle Bailey on 6/30/14.
//  Copyright (c) 2014 Kyle Bailey. All rights reserved.
//

#import "DataSource.h"

/*
    how does composed data source fucntion : 
        Does it hold multiple data source ? It seems like this due to function names
    Gives out data source at a particular location
    May be each bus route has a different data source etc <q>
 */


@interface ComposedDataSource : DataSource
@property (nonatomic) BOOL singleLoadingIndicator;

-(DataSource *)dataSourceAtIndex:(NSInteger)index;
-(void)addDataSource:(DataSource *)dataSource;
-(void)insertDataSource:(DataSource *)dataSource atIndex:(NSInteger)index;
-(void)removeDataSource:(DataSource *)dataSource;
-(void)removeAllDataSources;
@end