//
//  SegmentedDataSource.h
//  
//
//  Created by Kyle Bailey on 7/4/14.
//  Copyright (c) 2014 Kyle Bailey. All rights reserved.
//

#import "DataSource.h"

@interface SegmentedDataSource : DataSource
-(void)addDataSource:(DataSource *)dataSource;
-(void)removeDataSource:(DataSource *)dataSource;

/// The index of the selected data source in the collection.
@property (nonatomic) NSInteger selectedDataSourceIndex;

/// Set the index of the selected data source with optional animation. By default, setting the selected data source index is not animated.
- (void)setSelectedDataSourceIndex:(NSInteger)selectedDataSourceIndex animated:(BOOL)animated;

/// Call this method to configure a segmented control with the titles of the data sources. This method also sets the target & action of the segmented control to switch the selected data source.
- (void)configureSegmentedControl:(UISegmentedControl *)segmentedControl;

@end
