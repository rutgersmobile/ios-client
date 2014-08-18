//
//  RUSOCSearchDataSource.h
//  Rutgers
//
//  Created by Kyle Bailey on 8/12/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

#import "TupleDataSource.h"
#import "SearchDataSource.h"

@interface RUSOCSearchDataSource : TupleDataSource <SearchDataSource>
-(void)setNeedsLoadIndex;
@end
