//
//  EZTableViewSection.m
//  Rutgers
//
//  Created by Kyle Bailey on 5/19/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

#import "EZTableViewSection.h"
@interface EZTableViewSection ()
@property NSMutableArray *rows;
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
-(void)addRow:(EZTableViewRow *)row{
    [self.rows addObject:row];
}
-(void)addRows:(NSArray *)rows{
    [self.rows addObjectsFromArray:rows];
}
-(void)removeAllRows{
    [self.rows removeAllObjects];
}
-(NSInteger)numberOfRows{
    return self.rows.count;
}
-(EZTableViewRow *)rowAtIndex:(NSInteger)index{
    return self.rows[index];
}
@end
