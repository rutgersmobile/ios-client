//
//  ExpandingTableViewSection.h
//  Rutgers
//
//  Created by Kyle Bailey on 5/30/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

#import "EZDataSourceSection.h"


@interface ExpandingTableViewSection : EZDataSourceSection
-(instancetype)initWithHeaderRow:(EZTableViewAbstractRow *)headerRow bodyRows:(NSArray *)bodyRows;
@property (nonatomic) BOOL expanded;
@end
