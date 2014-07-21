//
//  EZTableViewSection.h
//  Rutgers
//
//  Created by Kyle Bailey on 5/19/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BasicDataSource.h"

@class EZDataSourceSection;

@class EZTableViewAbstractRow;

@interface EZDataSourceSection : BasicDataSource
-(instancetype)initWithSectionTitle:(NSString *)sectionTitle;
-(instancetype)initWithSectionTitle:(NSString *)sectionTitle items:(NSArray *)items;
-(instancetype)initWithItems:(NSArray *)rows;

@property (nonatomic) NSString *headerIdentifier;

-(void)addItem:(EZTableViewAbstractRow *)row;
-(void)addItems:(NSArray *)items;

-(EZTableViewAbstractRow *)itemAtIndex:(NSInteger)index;
@end
