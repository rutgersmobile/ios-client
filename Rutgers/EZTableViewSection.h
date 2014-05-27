//
//  EZTableViewSection.h
//  Rutgers
//
//  Created by Kyle Bailey on 5/19/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

#import <Foundation/Foundation.h>

@class EZTableViewRow;

@interface EZTableViewSection : NSObject
@property NSString *title;
-(instancetype)initWithSectionTitle:(NSString *)sectionTitle;
-(instancetype)initWithSectionTitle:(NSString *)sectionTitle rows:(NSArray *)rows;

-(void)addRow:(EZTableViewRow *)row;
-(void)addRows:(NSArray *)rows;

-(NSInteger)numberOfRows;
-(EZTableViewRow *)rowAtIndex:(NSInteger)index;
@end
