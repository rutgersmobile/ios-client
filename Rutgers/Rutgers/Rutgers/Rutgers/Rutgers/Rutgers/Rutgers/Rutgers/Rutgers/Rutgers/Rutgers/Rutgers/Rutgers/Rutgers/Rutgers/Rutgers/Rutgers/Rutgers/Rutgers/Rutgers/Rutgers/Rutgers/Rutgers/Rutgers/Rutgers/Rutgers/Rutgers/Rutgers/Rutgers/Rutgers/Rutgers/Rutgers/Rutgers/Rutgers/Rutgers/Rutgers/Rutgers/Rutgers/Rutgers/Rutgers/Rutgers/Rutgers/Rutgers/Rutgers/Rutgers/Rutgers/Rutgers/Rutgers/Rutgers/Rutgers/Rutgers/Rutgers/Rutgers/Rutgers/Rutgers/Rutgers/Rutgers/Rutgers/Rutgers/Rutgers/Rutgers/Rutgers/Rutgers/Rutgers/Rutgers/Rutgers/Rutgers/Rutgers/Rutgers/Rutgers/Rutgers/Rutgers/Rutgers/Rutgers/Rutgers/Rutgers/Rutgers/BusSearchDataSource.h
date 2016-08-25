//
//  BusSearchDataSource.h
//  Rutgers
//
//  Created by Kyle Bailey on 7/29/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

#import "ComposedDataSource.h"
#import "SearchDataSource.h"

@interface BusSearchDataSource : ComposedDataSource <SearchDataSource>

@end
