//
//  RUSOCSearchDataSource.h
//  Rutgers
//
//  Created by Kyle Bailey on 8/12/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

#import "ComposedDataSource.h"
#import "SearchDataSource.h"

@interface RUSOCSearchDataSource : ComposedDataSource <SearchDataSource>
-(void)setNeedsLoadIndex;
@end
