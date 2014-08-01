//
//  NSDictionary+SortValuesByTitle.m
//  Rutgers
//
//  Created by Kyle Bailey on 7/22/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

#import "NSDictionary+SortValuesByTitle.h"
#import "NSArray+SortByTitle.h"

@implementation NSDictionary (SortValuesByTitle)
-(NSArray *)sortedValuesByTitle{
    return [[self allValues] sortByTitle];
}
@end
