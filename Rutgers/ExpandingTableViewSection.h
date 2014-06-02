//
//  ExpandingTableViewSection.h
//  Rutgers
//
//  Created by Kyle Bailey on 5/30/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

#import "EZTableViewSection.h"

@interface ExpandingTableViewSection : EZTableViewSection
-(instancetype)initWithHeaderRow:(EZTableViewRow *)headerRow bodyRows:(NSArray *)bodyRows;
@property (nonatomic) BOOL expanded;
@end
