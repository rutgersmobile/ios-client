//
//  RUSOCCourseRow.h
//  Rutgers
//
//  Created by Kyle Bailey on 5/29/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

@interface RUSOCCourseRow : NSObject
-(instancetype)initWithCourse:(NSDictionary *)course NS_DESIGNATED_INITIALIZER;
@property (nonatomic) NSDictionary *course;
@property (nonatomic) NSString *titleText;
@property (nonatomic) NSString *creditsText;
@property (nonatomic) NSString *sectionText;
@end
