//
//  RUSOCCourseCell.h
//  Rutgers
//
//  Created by Kyle Bailey on 5/29/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

#import "ALTableViewAbstractCell.h"

@interface RUSOCCourseCell : ALTableViewAbstractCell
@property (strong, nonatomic) IBOutlet UILabel *titleLabel;
@property (strong, nonatomic) IBOutlet UILabel *creditsLabel;
@property (strong, nonatomic) IBOutlet UILabel *sectionsLabel;
@end
