//
//  RUSOCCourseSectionsDataSource.m
//  Rutgers
//
//  Created by Kyle Bailey on 8/15/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

#import "RUSOCCourseSectionsDataSource.h"
#import "RUSOCSectionCell.h"
#import "RUSOCSectionRow.h"

@implementation RUSOCCourseSectionsDataSource
- (instancetype)init
{
    self = [super init];
    if (self) {
        self.title = @"Sections";
    }
    return self;
}

-(void)setItems:(NSArray *)items{
    NSMutableArray *sections = [NSMutableArray array];

    NSPredicate *printedSectionsPredicate = [NSPredicate predicateWithFormat:@"printed == %@",@"Y"];
    for (NSDictionary *section in [items filteredArrayUsingPredicate:printedSectionsPredicate]) {
        [sections addObject:[[RUSOCSectionRow alloc] initWithSection:section]];
    }
    
    [super setItems:sections];
}

-(NSString *)reuseIdentifierForRowAtIndexPath:(NSIndexPath *)indexPath{
    return NSStringFromClass([RUSOCSectionCell class]);
}

-(void)configureCell:(RUSOCSectionCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    RUSOCSectionRow *row = [self itemAtIndexPath:indexPath];
    [row setupCell:cell];
    cell.separatorInset = UIEdgeInsetsZero;
}

@end