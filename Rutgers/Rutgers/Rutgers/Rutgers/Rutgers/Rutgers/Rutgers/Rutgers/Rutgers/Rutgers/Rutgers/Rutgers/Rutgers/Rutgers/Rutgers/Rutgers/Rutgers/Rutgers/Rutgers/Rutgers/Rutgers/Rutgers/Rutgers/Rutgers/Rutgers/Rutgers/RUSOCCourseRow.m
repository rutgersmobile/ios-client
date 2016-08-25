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

@end

@implementation RUSOCCourseRow
-(instancetype)initWithCourse:(NSDictionary *)course{
    self = [super init];
    if (self) {
        self.course = course;
        self.titleText = [NSString stringWithFormat:@"%@: %@",self.course[@"courseNumber"],[self.course[@"title"] capitalizedString]];
        if (self.course[@"credits"]) {
            self.creditsText = [NSString stringWithFormat:@"Credits: %@",self.course[@"credits"]];
        }
        NSPredicate *printedSectionsPredicate = [NSPredicate predicateWithFormat:@"printed == %@",@"Y"];
        NSPredicate *openSectionsPredicate = [NSPredicate predicateWithFormat:@"openStatus == YES"];

        NSArray *sections = [self.course[@"sections"] filteredArrayUsingPredicate:printedSectionsPredicate];
        NSArray *openSections = [sections filteredArrayUsingPredicate:openSectionsPredicate];
        
        self.sectionText = [NSString stringWithFormat:@"Sections: %lu / %lu",(unsigned long)openSections.count,(unsigned long)sections.count];
    }
    return self;
}

-(NSString *)textRepresentation{
    return self.titleText;
}
@end
