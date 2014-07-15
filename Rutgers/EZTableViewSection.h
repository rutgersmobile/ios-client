//
//  EZTableViewSection.h
//  Rutgers
//
//  Created by Kyle Bailey on 5/19/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

#import <Foundation/Foundation.h>

@class EZTableViewAbstractRow;

@interface EZTableViewSection : NSObject
@property (nonatomic) NSString *title;
-(instancetype)initWithSectionTitle:(NSString *)sectionTitle;
-(instancetype)initWithSectionTitle:(NSString *)sectionTitle rows:(NSArray *)rows;
-(instancetype)initWithRows:(NSArray *)rows;

@property (nonatomic) NSString *headerIdentifier;

-(void)addRow:(EZTableViewAbstractRow *)row;
-(void)addRows:(NSArray *)rows;
-(void)removeAllRows;
-(NSArray *)allRows;

-(NSInteger)numberOfRows;
-(EZTableViewAbstractRow *)rowAtIndex:(NSInteger)index;
@end
