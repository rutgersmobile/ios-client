//
//  ExpandingTableViewDataSource.h
//  Rutgers
//
//  Created by Kyle Bailey on 7/21/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

#import "ComposedDataSource.h"

/*
    Why is this a composed data source ? 
 
 */
@interface ExpandingTableViewDataSource : ComposedDataSource

@property (nonatomic) NSArray *sections; // holds the sections ? / Then why the multiple data sources in the composedDS ?
@property (nonatomic) BOOL isExpanded;

-(void)toggleExpansionForSection:(NSUInteger)section; // toogle whether the section has been expanded or not .

@end
