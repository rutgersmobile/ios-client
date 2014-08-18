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
-(void)setItems:(NSArray *)items{
    NSMutableArray *sections = [NSMutableArray array];

    NSPredicate *printedSectionsPredicate = [NSPredicate predicateWithFormat:@"printed == %@",@"Y"];
    for (NSDictionary *section in [items filteredArrayUsingPredicate:printedSectionsPredicate]) {
        [sections addObject:[[RUSOCSectionRow alloc] initWithSection:section]];
    }
    
    [super setItems:sections];
}

-(void)registerReusableViewsWithTableView:(UITableView *)tableView{
    [super registerReusableViewsWithTableView:tableView];
    [tableView registerClass:[RUSOCSectionCell class] forCellReuseIdentifier:NSStringFromClass([RUSOCSectionCell class])];
}

-(NSString *)reuseIdentifierForRowAtIndexPath:(NSIndexPath *)indexPath{
    return NSStringFromClass([RUSOCSectionCell class]);
}

-(void)configureCell:(id)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    RUSOCSectionRow *row = [self itemAtIndexPath:indexPath];
    [row setupCell:cell];
}

@end