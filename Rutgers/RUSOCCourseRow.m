//
//  RUSOCCourseRow.m
//  Rutgers
//
//  Created by Kyle Bailey on 5/29/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

#import "RUSOCCourseRow.h"
#import "RUSOCCourseCell.h"
@interface RUSOCCourseRow ()
@property (nonatomic) NSDictionary *course;
@end
@implementation RUSOCCourseRow
-(instancetype)initWithCourse:(NSDictionary *)course{
    self = [super initWithIdentifier:@"RUSOCCourseCell"];
    if (self) {
        self.course = course;
    }
    return self;
}

-(void)setupCell:(RUSOCCourseCell *)cell{
    cell.titleLabel.text = [NSString stringWithFormat:@"%@: %@",self.course[@"courseNumber"],[self.course[@"title"] capitalizedString]];
    id credits = self.course[@"credits"];
    if ([credits isKindOfClass:[NSNumber class]]) {
        cell.creditsLabel.text = [NSString stringWithFormat:@"Credits: %@",credits];
    } else {
        cell.creditsLabel.text = nil;
    }
    
    cell.sectionsLabel.text = nil;
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
}

@end
