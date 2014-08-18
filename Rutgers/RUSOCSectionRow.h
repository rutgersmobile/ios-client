//
//  RUSOCSectionRow.h
//  Rutgers
//
//  Created by Kyle Bailey on 6/18/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

#import "EZTableViewAbstractRow.h"

@class RUSOCSectionCell;

@interface RUSOCSectionRow : NSObject
-(instancetype)initWithSection:(NSDictionary *)section;
@property NSDictionary *section;
-(void)setupCell:(RUSOCSectionCell *)cell;
@end
