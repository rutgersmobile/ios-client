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
        self.noContentTitle = @"No listed sections";
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
    
    cell.indexLabel.text = row.indexText;
    cell.professorLabel.text = row.professorText;
    cell.descriptionLabel.text = row.descriptionText;
    cell.dayLabel.text = row.dayText;
    cell.timeLabel.text = row.timeText;
    cell.locationLabel.text = row.locationText;
    
    if ([row.section[@"openStatus"] boolValue]) {
        cell.backgroundColor = [UIColor colorWithRed:217/255.0 green:242/255.0 blue:213/255.0 alpha:1];
    } else {
        cell.backgroundColor = [UIColor colorWithRed:243/255.0 green:181/255.0 blue:181/255.0 alpha:1];
    }
    
    cell.separatorInset = UIEdgeInsetsZero;
}

@end