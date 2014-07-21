//
//  ComposedDataSource_Private.h
//  Rutgers
//
//  Created by Kyle Bailey on 7/21/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

#import "ComposedDataSource.h"

@interface ComposedDataSource () <DataSourceDelegate>
@property (nonatomic) NSMutableArray *dataSources;
@end