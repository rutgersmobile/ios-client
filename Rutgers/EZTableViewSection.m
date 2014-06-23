//
//  EZTableViewSection.m
//  Rutgers
//
//  Created by Kyle Bailey on 5/19/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

#import "EZTableViewSection.h"
#import "EZTableViewRightDetailRow.h"

@interface EZTableViewSection ()
@property (nonatomic) NSMutableArray *rows;
@property (nonatomic) EZTableViewRightDetailRow *emptyItem;
@end

@implementation EZTableViewSection
- (instancetype)init
{
    self = [super init];
    if (self) {
        self.rows = [NSMutableArray array];
    }
    return self;
}
-(instancetype)initWithSectionTitle:(NSString *)sectionTitle{
    self = [self init];
    if (self) {
        self.title = sectionTitle;
    }
    return self;
}
-(instancetype)initWithSectionTitle:(NSString *)sectionTitle rows:(NSArray *)rows{
    self = [self initWithSectionTitle:sectionTitle];
    if (self) {
        [self addRows:rows];
    }
    return self;
}

-(void)addRow:(EZTableViewRightDetailRow *)row{
    [self.rows addObject:row];
}

-(void)addRows:(NSArray *)rows{
    [self.rows addObjectsFromArray:rows];
}

-(void)removeAllRows{
    [self.rows removeAllObjects];
}

-(NSArray *)allRows{
    return self.rows;
}
/*
-(NSInteger)numberOfRows{
    return self.rows.count ;
}
-(EZTableViewRightDetailRow *)rowAtIndex:(NSInteger)index{
    return self.rows[index];
}*/

-(NSInteger)numberOfRows{
    return self.rows.count;// ? self.rows.count : 1;
}

-(EZTableViewRightDetailRow *)rowAtIndex:(NSInteger)index{
    return self.rows[index];// : self.emptyItem;
}
/*
-(NSString *)emptyItemFormat{
    if (!_emptyItemFormat) {
        _emptyItemFormat = @"No %@";
    }
    return _emptyItemFormat;
}

-(EZTableViewRightDetailRow *)emptyItem{
    if (!_emptyItem) {
        NSString *text;
        if (self.title) {
            text = [NSString stringWithFormat:self.emptyItemFormat,self.title];
        } else {
            text = @"No Items";
        }
        _emptyItem = [[EZTableViewRightDetailRow alloc] initWithText:text];
    }
    return _emptyItem;
}*/
@end
